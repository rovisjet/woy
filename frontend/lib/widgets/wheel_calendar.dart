import 'package:flutter/material.dart';
import '../models/ring_model.dart';
import '../data/rings_data.dart';
import 'ring.dart';

class WheelCalendar extends StatefulWidget {
  const WheelCalendar({Key? key}) : super(key: key);

  @override
  State<WheelCalendar> createState() => _WheelCalendarState();
}

class _WheelCalendarState extends State<WheelCalendar> {
  final List<Ring> rings = RingsData.rings;
  Ring? selectedRing;

  void _handleTap(Offset position) {
    final center = const Offset(200, 200);
    final distance = (position - center).distance;

    // Check rings from outer to inner
    for (final ring in rings.reversed) {
      if (distance >= ring.innerRadius && 
          distance <= (ring.innerRadius + ring.thickness)) {
        setState(() {
          selectedRing = selectedRing == ring ? null : ring;
        });
        print('Selected ring: ${ring.name}');
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) => _handleTap(details.localPosition),
      child: SizedBox(
        width: 400,
        height: 400,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...rings.map((ring) => RingWidget(
              ring: ring,
              isSelected: ring == selectedRing,
              dayRotation: 0,
              onTap: () => setState(() {
                selectedRing = selectedRing == ring ? null : ring;
                print('Selected ring: ${ring.name}');
              }),
            )).toList().reversed,
          ],
        ),
      ),
    );
  }
}