import 'package:flutter/material.dart';
import 'widgets/ring.dart';
import 'widgets/central_circle.dart';
import 'models/era_model.dart';
import 'models/ring_model.dart';
import 'package:intl/intl.dart';
import 'screens/ring_list_view.dart';
import 'data/rings_data.dart';
import 'dart:math' as math;
import 'widgets/ring_management_modal.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wheel Calendar',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[850],
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

class DayEvent {
  final String title;
  final String description;
  final Color color;

  DayEvent({
    required this.title,
    required this.description,
    required this.color,
  });
}

// Create a global key for WheelCalendar
final GlobalKey<WheelCalendarState> wheelCalendarKey = GlobalKey<WheelCalendarState>();

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FutureBuilder<User?>(
          future: ApiService.fetchCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }
            
            if (snapshot.hasData && snapshot.data != null) {
              return Text(
                'Hello, ${snapshot.data!.username}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              );
            } 
            
            return const SizedBox.shrink();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              _showRingManagementModal(context);
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RingListView()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: WheelCalendar(key: wheelCalendarKey),
      ),
    );
  }

  Future<void> _showRingManagementModal(BuildContext context) async {
    final wheelCalendarState = wheelCalendarKey.currentState;
    
    if (wheelCalendarState != null) {
      try {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading rings...'),
            duration: Duration(seconds: 1),
          ),
        );
        
        // Fetch public rings
        final publicRings = await ApiService.fetchPublicRings();
        
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return RingManagementModal(
                userRings: wheelCalendarState.rings,
                publicRings: publicRings,
                onRingsUpdated: (updatedRings) {
                  // Update the rings in the WheelCalendar
                  wheelCalendarState.updateRings(updatedRings);
                },
              );
            },
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load rings: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // If we can't find the state, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not access wheel calendar state'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class WheelCalendar extends StatefulWidget {
  const WheelCalendar({Key? key}) : super(key: key);

  @override
  WheelCalendarState createState() => WheelCalendarState();
}

class WheelCalendarState extends State<WheelCalendar> {
  late List<Ring> rings;
  int? selectedRingIndex;
  double currentDay = 0;
  List<double> ringDays = List.generate(13, (index) => 0.0);
  bool isSliding = false;
  bool showLabels = false;
  bool isLoading = true;
  
  final DateFormat dateFormat = DateFormat('EEEE, MMMM d, yyyy');
  final easternTimeZone = DateTime.now().toUtc().subtract(const Duration(hours: 5));

  @override
  void initState() {
    super.initState();
    // Initially use the fallback data
    rings = RingsData.rings;
    // Then fetch from API
    _fetchRingsFromApi();
  }

  // This method will be called from the HomeScreen when rings are updated
  void updateRings(List<Ring> updatedRings) {
    // Create a copy of updatedRings with updated indices
    final List<Ring> reindexedRings = [];
    
    // Create new ring objects with updated indices based on their order
    for (int i = 0; i < updatedRings.length; i++) {
      final ring = updatedRings[i];
      // Create a new Ring with updated index
      reindexedRings.add(Ring(
        id: ring.id,
        index: i, // Use position in the list as the index
        name: ring.name,
        innerRadius: 0, // Will be calculated later
        thickness: ring.thickness,
        numberOfTicks: ring.numberOfTicks,
        baseColor: ring.baseColor,
        eras: ring.eras,
        events: ring.events,
        useImages: ring.useImages,
        imageAssets: ring.imageAssets,
      ));
    }
    
    // Update inner radii based on new indices and count
    final recalculatedRings = _recalculateRingRadii(reindexedRings);
    
    // Update ringDays array size if needed
    if (recalculatedRings.length > ringDays.length) {
      ringDays = List.generate(recalculatedRings.length, (index) => currentDay);
    }
    
    setState(() {
      rings = recalculatedRings;
      
      // Reset selected ring if it's no longer available
      if (selectedRingIndex != null && 
          !recalculatedRings.any((ring) => ring.index == selectedRingIndex)) {
        selectedRingIndex = null;
      }
    });
  }
  
  // Helper method to recalculate ring radii based on count and order
  List<Ring> _recalculateRingRadii(List<Ring> rings) {
    const double CANVAS_SIZE = 400.0;
    const double CENTER_CIRCLE_RADIUS = 50.0;
    const double DEFAULT_THICKNESS = 20.0;
    const double RING_SPACING = 10.0;
    
    // Available space is from center circle to edge of canvas
    double availableSpace = (CANVAS_SIZE / 2) - CENTER_CIRCLE_RADIUS;
    
    // Total space needed for all rings and gaps
    double totalRingSpace = (rings.length * DEFAULT_THICKNESS) + 
                           ((rings.length - 1) * RING_SPACING);
                           
    // Scale factor to fit everything
    double scaleFactor = availableSpace / totalRingSpace;
    
    List<Ring> result = [];
    
    // Calculate inner radius for each ring
    for (int i = 0; i < rings.length; i++) {
      final ring = rings[i];
      
      // Calculate inner radius with spacing
      double innerRadius = CENTER_CIRCLE_RADIUS;
      for (int j = 0; j < i; j++) {
        innerRadius += (DEFAULT_THICKNESS * scaleFactor) + (RING_SPACING * scaleFactor);
      }
      
      // Create a new ring with the calculated inner radius
      result.add(Ring(
        id: ring.id,
        index: ring.index,
        name: ring.name,
        innerRadius: innerRadius,
        thickness: DEFAULT_THICKNESS * scaleFactor,
        numberOfTicks: ring.numberOfTicks,
        baseColor: ring.baseColor,
        eras: ring.eras,
        events: ring.events,
        useImages: ring.useImages,
        imageAssets: ring.imageAssets,
      ));
    }
    
    return result;
  }

  Future<void> _fetchRingsFromApi() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      // Try to fetch user's rings first
      try {
        final userRings = await ApiService.fetchUserRings();
        if (userRings.isNotEmpty) {
          // Ensure the rings have proper indices and spacing
          final processedRings = _recalculateRingRadii(userRings);
          
          setState(() {
            rings = processedRings;
            isLoading = false;
          });
          return;
        }
      } catch (e) {
        print('Error fetching user rings, falling back to all rings: $e');
      }
      
      // If user has no rings or an error occurred, fall back to all rings
      final fetchedRings = await RingsData.fetchRings();
      
      // Ensure the rings have proper indices and spacing
      final processedRings = _recalculateRingRadii(fetchedRings);
      
      setState(() {
        rings = processedRings;
        isLoading = false;
      });
    } catch (e) {
      print('Error in _fetchRingsFromApi: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDailySnapshot() {
    final events = [
      DayEvent(
        title: 'Menstrual Phase',
        description: '3/28',
        color: Colors.pink,
      ),
      DayEvent(
        title: 'Waxing Crescent',
        description: '8/29',
        color: Colors.blue,
      ),
      DayEvent(
        title: 'Early Spring',
        description: '45/365',
        color: Colors.green,
      ),
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM d').format(
                  easternTimeZone.add(Duration(days: currentDay.round()))
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: events.map((event) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: event.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: event.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: event.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.title,
                        style: TextStyle(
                          color: event.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.description,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'On this day, you are in your menstrual phase coinciding with a waxing crescent moon during early spring. This combination traditionally symbolizes a period of release and renewal, as the growing moon supports the body\'s natural cleansing process while spring energy encourages new beginnings.',
                style: TextStyle(
                  color: Colors.grey[300],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayLabel(double value) {
    if (value == 0) {
      return 'Today';
    }
    final date = easternTimeZone.add(Duration(days: value.round()));
    return dateFormat.format(date);
  }

  String _getSliderLabel(double value) {
    if (value == 0) {
      return 'Today';
    }
    final date = easternTimeZone.add(Duration(days: value.round()));
    return DateFormat('MMM d, yyyy').format(date);
  }

  void _onRingTap(int index) {
    setState(() {
      if (selectedRingIndex != index) {
        selectedRingIndex = index;
        final maxDays = rings[selectedRingIndex!].numberOfTicks.toDouble();
        if (currentDay > maxDays) {
          currentDay = maxDays;
          for (int i = 0; i < ringDays.length; i++) {
            ringDays[i] = currentDay;
          }
        }
      }
    });
  }

  void _onSliderChanged(double value) {
    setState(() {
      isSliding = true;
      // Ensure value is within bounds
      final maxDays = rings[selectedRingIndex!].numberOfTicks.toDouble();
      currentDay = value.clamp(0, maxDays);
      ringDays[selectedRingIndex!] = currentDay;
    });
  }

  void _onSliderChangeEnd(double value) {
    setState(() {
      isSliding = false;
      // Ensure value is within bounds
      final maxDays = rings[selectedRingIndex!].numberOfTicks.toDouble();
      currentDay = value.clamp(0, maxDays);
      for (int i = 0; i < ringDays.length; i++) {
        ringDays[i] = currentDay;
      }
    });
  }

  Color _getSelectedRingColor() {
    if (selectedRingIndex == null) return Colors.grey;
    return rings[selectedRingIndex!].baseColor;
  }

  double _getSliderMax() {
    return selectedRingIndex == null ? 0 : rings[selectedRingIndex!].numberOfTicks.toDouble();
  }

  int _calculateDivisionsForRing(int numberOfTicks) {
    // Calculate appropriate divisions that make sense for the number of ticks
    // The goal is to show logical intervals (e.g. 5, 10, 30 days) without overwhelming the UI
    
    // For very small cycles (< 30 days), show all days
    if (numberOfTicks <= 30) {
      return numberOfTicks - 1;
    }
    
    // For medium cycles, show intervals that are easily counted
    else if (numberOfTicks <= 60) {
      return (numberOfTicks ~/ 2); // Show every 2 days
    }
    else if (numberOfTicks <= 120) {
      return (numberOfTicks ~/ 5); // Show every 5 days
    }
    else if (numberOfTicks <= 180) {
      return (numberOfTicks ~/ 10); // Show every 10 days
    }
    // For annual cycles, show monthly or bi-weekly intervals
    else if (numberOfTicks <= 366) {
      return (numberOfTicks ~/ 30); // ~12 divisions for a year
    }
    
    // For very large cycles, limit to reasonable number of tick marks
    return (numberOfTicks ~/ (numberOfTicks / 20)).toInt(); // About 20 marks max
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Loading rings data...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            _getDayLabel(currentDay),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        if (selectedRingIndex != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: rings[selectedRingIndex!].baseColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: rings[selectedRingIndex!].baseColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  rings[selectedRingIndex!].name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: rings[selectedRingIndex!].baseColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          )
        else
          const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: showLabels,
                onChanged: (value) {
                  setState(() {
                    showLabels = value ?? false;
                  });
                },
                activeColor: _getSelectedRingColor(),
                checkColor: Colors.white,
              ),
              const Text(
                'Show Labels',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 400,
          height: 400,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final center = Offset(200, 200);
              final distance = (details.localPosition - center).distance;
              
              // Check rings from outer to inner
              for (var i = rings.length - 1; i >= 0; i--) {
                final ring = rings[i];
                if (distance >= ring.innerRadius && 
                    distance <= (ring.innerRadius + ring.thickness)) {
                  setState(() {
                    selectedRingIndex = ring.index;
                  });
                  break;
                }
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                ...rings.map((ring) => RingWidget(
                  ring: ring,
                  isSelected: selectedRingIndex == ring.index,
                  onTap: () {}, // Empty callback since we handle taps above
                  dayRotation: ringDays[ring.index < ringDays.length ? ring.index : 0],
                  animationEnabled: !isSliding || selectedRingIndex == ring.index,
                  showLabels: showLabels,
                )).toList().reversed,
                CentralCircle(radius: 50, onTap: _showDailySnapshot),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Opacity(
              opacity: selectedRingIndex != null ? 1.0 : 0.0,
              child: Row(
                children: [
                  // Previous day button
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: _getSelectedRingColor(),
                    ),
                    onPressed: selectedRingIndex != null ? () {
                      if (currentDay > 0) {
                        setState(() {
                          currentDay = currentDay - 1;
                          ringDays[selectedRingIndex!] = currentDay;
                          for (int i = 0; i < ringDays.length; i++) {
                            ringDays[i] = currentDay;
                          }
                        });
                      }
                    } : null,
                  ),
                  // Slider with appropriate tick marks
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: _getSelectedRingColor(),
                        thumbColor: _getSelectedRingColor(),
                        overlayColor: _getSelectedRingColor().withOpacity(0.3),
                        valueIndicatorColor: _getSelectedRingColor(),
                        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3),
                        activeTickMarkColor: _getSelectedRingColor().withOpacity(0.9),
                        inactiveTickMarkColor: _getSelectedRingColor().withOpacity(0.6),
                        showValueIndicator: ShowValueIndicator.always,
                        trackHeight: 2.5,
                      ),
                      child: Slider(
                        value: currentDay,
                        min: 0,
                        max: _getSliderMax(),
                        // Calculate appropriate number of divisions based on available width
                        divisions: selectedRingIndex != null 
                          ? _calculateDivisionsForRing(rings[selectedRingIndex!].numberOfTicks) 
                          : 1,
                        label: _getSliderLabel(currentDay),
                        onChanged: selectedRingIndex != null ? _onSliderChanged : null,
                        onChangeEnd: selectedRingIndex != null ? _onSliderChangeEnd : null,
                      ),
                    ),
                  ),
                  // Next day button
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: _getSelectedRingColor(),
                    ),
                    onPressed: selectedRingIndex != null ? () {
                      final maxDays = rings[selectedRingIndex!].numberOfTicks.toDouble();
                      if (currentDay < maxDays - 1) {
                        setState(() {
                          currentDay = currentDay + 1;
                          ringDays[selectedRingIndex!] = currentDay;
                          for (int i = 0; i < ringDays.length; i++) {
                            ringDays[i] = currentDay;
                          }
                        });
                      }
                    } : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}