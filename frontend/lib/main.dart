import 'package:flutter/material.dart';
import 'widgets/ring.dart';
import 'widgets/central_circle.dart';
import 'models/era_model.dart';
import 'models/ring_model.dart';
import 'package:intl/intl.dart';
import 'screens/ring_list_view.dart';
import 'data/rings_data.dart';
import 'dart:math' as math;

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
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
      body: const Center(
        child: WheelCalendar(),
      ),
    );
  }
}

class WheelCalendar extends StatefulWidget {
  const WheelCalendar({Key? key}) : super(key: key);

  @override
  State<WheelCalendar> createState() => _WheelCalendarState();
}

class _WheelCalendarState extends State<WheelCalendar> {
  late final List<Ring> rings;
  int? selectedRingIndex;
  double currentDay = 0;
  List<double> ringDays = List.generate(13, (index) => 0.0);
  bool isSliding = false;
  bool showLabels = false;
  
  final DateFormat dateFormat = DateFormat('EEEE, MMMM d, yyyy');
  final easternTimeZone = DateTime.now().toUtc().subtract(const Duration(hours: 5));

  @override
  void initState() {
    super.initState();
    rings = RingsData.rings;
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
              for (var ring in rings.reversed) {
                if (distance >= ring.innerRadius && 
                    distance <= (ring.innerRadius + ring.thickness)) {
                  _onRingTap(ring.index);
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
                  dayRotation: ringDays[ring.index],
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