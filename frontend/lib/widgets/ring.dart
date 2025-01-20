import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/era_model.dart';

class RingWidget extends StatefulWidget {
  final int index;
  final double innerRadius;
  final double thickness;
  final int numberOfTicks;
  final Color baseColor;
  final bool isSelected;
  final double dayRotation;
  final bool animationEnabled;
  final List<Era> eras;

  const RingWidget({
    Key? key,
    required this.index,
    required this.innerRadius,
    required this.thickness,
    required this.numberOfTicks,
    required this.baseColor,
    required this.isSelected,
    required this.dayRotation,
    required this.animationEnabled,
    required this.eras,
  }) : super(key: key);

  @override
  State<RingWidget> createState() => _RingState();
}

class _RingState extends State<RingWidget> with SingleTickerProviderStateMixin {
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
      final newRotation = (widget.dayRotation * 2 * math.pi) / widget.numberOfTicks;
      
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
    return SizedBox(
      width: 400,
      height: 400,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: CustomPaint(
              size: const Size(400, 400),
              painter: RingPainter(
                innerRadius: widget.innerRadius,
                thickness: widget.thickness,
                numberOfTicks: widget.numberOfTicks,
                baseColor: widget.baseColor,
                isSelected: widget.isSelected,
                eras: widget.eras,
              ),
            ),
          );
        },
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  final double innerRadius;
  final double thickness;
  final int numberOfTicks;
  final Color baseColor;
  final bool isSelected;
  final List<Era> eras;
  
  RingPainter({
    required this.innerRadius,
    required this.thickness,
    required this.numberOfTicks,
    required this.baseColor,
    required this.isSelected,
    required this.eras,
  });

 @override
void paint(Canvas canvas, Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  
  // Draw eras
  for (var era in eras) {
    final startAngle = (era.startDay * 2 * math.pi) / numberOfTicks;
    final sweepAngle = ((era.endDay - era.startDay) * 2 * math.pi) / numberOfTicks;
    
    final eraPaint = Paint()
      ..color = era.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    
    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: innerRadius + (thickness / 2),
      ),
      startAngle - math.pi / 2, // Adjust to start from top
      sweepAngle,
      false,
      eraPaint,
    );

    // Calculate middle angle for label placement
    final middleAngle = startAngle + (sweepAngle / 2) - math.pi / 2;
    _drawEraLabel(
      canvas,
      center,
      era.name,
      middleAngle,
      innerRadius + (thickness / 2),
    );
  }
    
    // Draw tick marks
    final tickPaint = Paint()
      ..color = isSelected ? baseColor : baseColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.0 : 1.0;
    
    final tickLength = isSelected ? 8.0 : 5.0;
    
    for (int i = 0; i < numberOfTicks; i++) {
      final angle = (2 * math.pi * i) / numberOfTicks;
      final outerPoint = Offset(
        center.dx + (innerRadius + thickness) * math.cos(angle),
        center.dy + (innerRadius + thickness) * math.sin(angle)
      );
      final innerPoint = Offset(
        center.dx + (innerRadius + thickness - tickLength) * math.cos(angle),
        center.dy + (innerRadius + thickness - tickLength) * math.sin(angle)
      );
      
      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }
  }

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}