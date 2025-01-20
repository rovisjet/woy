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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 350,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final center = Offset(box.size.width / 2, box.size.height / 2);
          final position = details.localPosition;
          _handleTap(position, center);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...rings.map((ring) => RingWidget(
              ring: ring,
              isSelected: ring == selectedRing,
              dayRotation: 0,
              onTap: () => setState(() {
                selectedRing = selectedRing == ring ? null : ring;
              }),
            )).toList().reversed,
          ],
        ),
      ),
    );
  }

  void _handleTap(Offset position, Offset center) {
    final distance = (position - center).distance;
    
    // Check rings from outer to inner
    for (final ring in rings.reversed) {
      final ringOuter = ring.innerRadius + ring.thickness;
      final ringInner = ring.innerRadius;
      
      if (distance >= ringInner && distance <= ringOuter) {
        setState(() {
          selectedRing = selectedRing == ring ? null : ring;
        });
        break;
      }
    }
  }
}