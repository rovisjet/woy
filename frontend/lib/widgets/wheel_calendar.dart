import 'package:flutter/material.dart';
import 'central_circle.dart';
import 'ring.dart';
import '../data/rings_data.dart';
import '../models/ring_model.dart';
import 'package:intl/intl.dart';

class WheelCalendar extends StatefulWidget {
  const WheelCalendar({Key? key}) : super(key: key);

  @override
  _WheelCalendarState createState() => _WheelCalendarState();
}

class _WheelCalendarState extends State<WheelCalendar> {
  late final List<Ring> rings;
  int? selectedRingIndex;
  double currentDay = 0;
  late List<double> ringDays;
  bool isSliding = false;
  
  final DateFormat dateFormat = DateFormat('EEEE, MMMM d, yyyy');
  final easternTimeZone = DateTime.now().toUtc().subtract(const Duration(hours: 5));

  @override
  void initState() {
    super.initState();
    rings = RingsData.rings;
    ringDays = List.filled(rings.length, 0);
  }

  void _onRingTap(int index) {
    setState(() {
      selectedRingIndex = index;
      currentDay = ringDays[index];
    });
  }

  void _onSliderChanged(double value) {
    if (selectedRingIndex == null) return;
    setState(() {
      isSliding = true;
      currentDay = value;
      ringDays[selectedRingIndex!] = value;
    });
  }

  void _onSliderChangeEnd(double value) {
    if (selectedRingIndex == null) return;
    setState(() {
      isSliding = false;
      ringDays[selectedRingIndex!] = value;
    });
  }

  Color _getSelectedRingColor() {
    return selectedRingIndex == null ? Colors.grey : rings[selectedRingIndex!].baseColor;
  }

  double _getSliderMax() {
    if (selectedRingIndex == null) return 0;
    return rings[selectedRingIndex!].numberOfTicks.toDouble();
  }

  String _getDayLabel(double day) {
    return dateFormat.format(easternTimeZone.add(Duration(days: day.round())));
  }

  void _showDailySnapshot() {
    // Implementation of _showDailySnapshot method
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            _getDayLabel(currentDay),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          width: 400,
          height: 400,
          color: Colors.transparent,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final center = Offset(200, 200);
              final distance = (details.localPosition - center).distance;
              
              print('\n=== Tap Details ===');
              print('Tap position: ${details.localPosition}');
              print('Distance from center: $distance');
              
              // Check rings from outer to inner
              for (final ring in rings.reversed) {
                final outerRadius = ring.innerRadius + ring.thickness;
                print('Checking Ring ${ring.index} (${ring.name}): ${ring.innerRadius} to $outerRadius');
                
                if (distance >= ring.innerRadius && distance <= outerRadius) {
                  print('Selected Ring ${ring.index} (${ring.name})');
                  _onRingTap(ring.index);
                  break;
                }
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                ...rings.reversed.map((ring) => RingWidget(
                  index: ring.index,
                  innerRadius: ring.innerRadius,
                  thickness: ring.thickness,
                  numberOfTicks: ring.numberOfTicks,
                  baseColor: ring.baseColor,
                  isSelected: selectedRingIndex == ring.index,
                  dayRotation: ringDays[ring.index],
                  animationEnabled: !isSliding || selectedRingIndex == ring.index,
                  eras: ring.eras,
                )).toList(),
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
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: _getSelectedRingColor(),
                  thumbColor: _getSelectedRingColor(),
                  overlayColor: _getSelectedRingColor().withOpacity(0.3),
                  valueIndicatorColor: _getSelectedRingColor(),
                ),
                child: Slider(
                  value: currentDay,
                  min: 0,
                  max: _getSliderMax(),
                  divisions: selectedRingIndex != null ? _getSliderMax().toInt() : 1,
                  label: _getDayLabel(currentDay),
                  onChanged: selectedRingIndex != null ? _onSliderChanged : null,
                  onChangeEnd: selectedRingIndex != null ? _onSliderChangeEnd : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}