import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CentralCircle extends StatelessWidget {
  final double radius;
  final VoidCallback onTap;

  const CentralCircle({
    Key? key,
    required this.radius,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/images/symbols/pentacle.svg',
            width: radius * 1.8,
            height: radius * 1.8,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}

class CentralCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, size.width / 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}