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
        scaffoldBackgroundColor: Colors.transparent, // Changed to transparent to allow our background image to show
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showingLabels = false;

  @override
  void initState() {
    super.initState();
    // Need to wait for the next frame when wheelCalendarKey will be available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = wheelCalendarKey.currentState;
      if (state != null && mounted) {
        // Set initial state
        setState(() {
          _showingLabels = state.areLabelsVisible;
        });
        
        // Register callback for future changes
        state.setOnLabelsChangedCallback((isVisible) {
          if (mounted) {
            setState(() {
              _showingLabels = isVisible;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to extend behind the AppBar
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
            icon: Icon(
              Icons.local_offer, // Shopping tag icon
              color: _showingLabels ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            tooltip: 'Toggle Labels',
            onPressed: () {
              final state = wheelCalendarKey.currentState;
              if (state != null) {
                state.toggleLabels();
                setState(() {
                  _showingLabels = state.areLabelsVisible;
                });
              }
            },
          ),
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
      // Container with background image
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/forest_mist_bg.jpg'),
            fit: BoxFit.cover, // Cover the entire screen
          ),
        ),
        child: Stack(
          children: [
            // Semi-transparent overlay for better readability
            Container(
              color: Colors.black.withOpacity(0.4), // Adjust opacity as needed
            ),
            // Main content
            Center(
              child: WheelCalendar(key: wheelCalendarKey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRingManagementModal(BuildContext context) async {
    final wheelCalendarState = wheelCalendarKey.currentState;
    
    if (wheelCalendarState != null) {
      try {
        // Reset the current day to today (0) whenever opening the editor
        wheelCalendarState.resetToToday();
        
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
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rings updated successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
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
  int? selectedRingIndex; // Keep this for backward compatibility but we won't use it
  double currentDay = 0;
  List<double> ringDays = List.generate(13, (index) => 0.0);
  bool isLoading = true;
  bool showLabels = false;
  
  // Callback for when labels visibility changes
  Function(bool)? _onLabelsChanged;
  
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

  // Set a callback to notify when labels change
  void setOnLabelsChangedCallback(Function(bool) callback) {
    _onLabelsChanged = callback;
  }

  // Reset the calendar to today (day 0)
  void resetToToday() {
    setState(() {
      currentDay = 0;
      // Reset all ring days to 0
      for (int i = 0; i < ringDays.length; i++) {
        ringDays[i] = 0;
      }
    });
  }
  
  // Toggle the labels visibility
  void toggleLabels() {
    setState(() {
      showLabels = !showLabels;
      
      // Notify callback if set
      if (_onLabelsChanged != null) {
        _onLabelsChanged!(showLabels);
      }
    });
  }
  
  // Get the current labels state
  bool get areLabelsVisible => showLabels;

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
    
    // Ensure currentDay is valid
    if (selectedRingIndex != null && selectedRingIndex! < rings.length) {
      final maxDays = rings[selectedRingIndex!].numberOfTicks.toDouble();
      if (currentDay > maxDays) {
        // Schedule this for the next frame to avoid setState during build
        Future.microtask(() {
          setState(() {
            currentDay = maxDays;
            for (int i = 0; i < ringDays.length; i++) {
              ringDays[i] = currentDay;
            }
          });
        });
      }
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Date navigation row with left/right arrows and date in center
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous day button
              IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    currentDay = currentDay - 1;
                    // Update all rings to the new day
                    for (int i = 0; i < ringDays.length; i++) {
                      ringDays[i] = currentDay;
                    }
                  });
                },
              ),
              // Date display (clickable)
              GestureDetector(
                onTap: () => _showDatePicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getDayLabel(currentDay),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Next day button
              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    currentDay = currentDay + 1;
                    // Update all rings to the new day
                    for (int i = 0; i < ringDays.length; i++) {
                      ringDays[i] = currentDay;
                    }
                  });
                },
              ),
            ],
          ),
        ),
        SizedBox(
          width: 400,
          height: 400,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...rings.map((ring) {
                // Find ring's position in the array
                final ringPosition = rings.indexOf(ring);
                return RingWidget(
                  ring: ring,
                  isSelected: false, // No selected state anymore as we don't select individual rings
                  onTap: () {}, // Empty callback since we don't select rings anymore
                  dayRotation: ringDays.length > ringPosition ? ringDays[ringPosition] : 0.0,
                  animationEnabled: true, // Always animate all rings
                  showLabels: showLabels,
                );
              }).toList().reversed,
              CentralCircle(radius: 50, onTap: _showDailySnapshot),
            ],
          ),
        ),
        // Space for future menu items
        const SizedBox(height: 60),
      ],
    );
  }

  // New method to show the date picker
  Future<void> _showDatePicker(BuildContext context) async {
    final now = easternTimeZone;
    final selectedDate = now.add(Duration(days: currentDay.round()));
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white70,
              onPrimary: Colors.black,
              surface: Color(0xFF303030),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[850],
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      // Calculate the difference in days between the picked date and today
      final difference = pickedDate.difference(now).inDays;
      
      setState(() {
        currentDay = difference.toDouble();
        // Update all rings to the new date
        for (int i = 0; i < ringDays.length; i++) {
          ringDays[i] = currentDay;
        }
      });
    }
  }
}