import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/ring_model.dart';

class RingWidget extends StatefulWidget {
  final Ring ring;
  final bool isSelected;
  final VoidCallback onTap;
  final double dayRotation;
  final bool animationEnabled;

  const RingWidget({
    Key? key,
    required this.ring,
    required this.isSelected,
    required this.onTap,
    required this.dayRotation,
    this.animationEnabled = true,
  }) : super(key: key);

  @override
  State<RingWidget> createState() => _RingWidgetState();
}

class _RingWidgetState extends State<RingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  double _currentRotation = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dayRotation != widget.dayRotation) {
      final newRotation = (widget.dayRotation * 2 * math.pi) / widget.ring.numberOfTicks;
      
      if (widget.animationEnabled) {
        _rotationAnimation = Tween<double>(
          begin: _currentRotation,
          end: newRotation,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
        _controller.forward(from: 0);
      } else {
        _rotationAnimation = Tween<double>(
          begin: newRotation,
          end: newRotation,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
      }
      _currentRotation = newRotation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: CustomPaint(
            size: const Size(400, 400),
            painter: RingPainter(
              ring: widget.ring,
              isSelected: widget.isSelected,
            ),
          ),
        );
      },
    );
  }
}

class RingPainter extends CustomPainter {
  final Ring ring;
  final bool isSelected;

  RingPainter({
    required this.ring,
    required this.isSelected,
  });

  void _drawEraLabel(Canvas canvas, Offset center, String text, double angle, double radius) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final double x = center.dx + radius * math.cos(angle);
    final double y = center.dy + radius * math.sin(angle);

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle + math.pi/2);
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw eras
    for (var era in ring.eras) {
      final startAngle = (era.startDay * 2 * math.pi) / ring.numberOfTicks;
      final sweepAngle = ((era.endDay - era.startDay) * 2 * math.pi) / ring.numberOfTicks;
      
      final eraPaint = Paint()
        ..color = era.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.thickness;
      
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: ring.innerRadius + (ring.thickness / 2),
        ),
        startAngle - math.pi / 2, // Adjust to start from top
        sweepAngle,
        false,
        eraPaint,
      );

      // Draw era label
      final middleAngle = startAngle + (sweepAngle / 2) - math.pi / 2;
      _drawEraLabel(
        canvas,
        center,
        era.name,
        middleAngle,
        ring.innerRadius + (ring.thickness / 2),
      );
    }
    
    // Draw tick marks
    final tickPaint = Paint()
      ..color = isSelected ? ring.baseColor : ring.baseColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.0 : 1.0;
    
    final tickLength = isSelected ? 8.0 : 5.0;
    
    for (int i = 0; i < ring.numberOfTicks; i++) {
      final angle = (2 * math.pi * i) / ring.numberOfTicks;
      final outerPoint = Offset(
        center.dx + (ring.innerRadius + ring.thickness) * math.cos(angle),
        center.dy + (ring.innerRadius + ring.thickness) * math.sin(angle)
      );
      final innerPoint = Offset(
        center.dx + (ring.innerRadius + ring.thickness - tickLength) * math.cos(angle),
        center.dy + (ring.innerRadius + ring.thickness - tickLength) * math.sin(angle)
      );
      
      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected || oldDelegate.ring != ring;
  }
}