import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import '../models/ring_model.dart';

class RingWidget extends StatefulWidget {
  final Ring ring;
  final bool isSelected;
  final VoidCallback onTap;
  final double dayRotation;
  final bool animationEnabled;
  final bool showLabels;

  const RingWidget({
    Key? key,
    required this.ring,
    required this.isSelected,
    required this.onTap,
    required this.dayRotation,
    this.animationEnabled = true,
    this.showLabels = false,
  }) : super(key: key);

  @override
  State<RingWidget> createState() => _RingWidgetState();
}

class _RingWidgetState extends State<RingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  double _currentRotation = 0;
  List<ImageProvider?> _loadedImages = [];

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
    
    _loadImages();
  }

  void _loadImages() {
    if (widget.ring.useImages) {
      _loadedImages = List.generate(
        widget.ring.imageAssets.length, 
        (index) => AssetImage(widget.ring.imageAssets[index])
      );
    }
  }

  @override
  void didUpdateWidget(RingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update loaded images if the ring or imageAssets changed
    if (oldWidget.ring != widget.ring || 
        oldWidget.ring.imageAssets != widget.ring.imageAssets) {
      _loadImages();
    }
    
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ring.useImages) {
      return AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: ImageRing(
              ring: widget.ring,
              isSelected: widget.isSelected,
              imageAssets: widget.ring.imageAssets,
            ),
          );
        },
      );
    } else {
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
                showLabels: widget.showLabels,
              ),
            ),
          );
        },
      );
    }
  }
}

class ImageRing extends StatelessWidget {
  final Ring ring;
  final bool isSelected;
  final List<String> imageAssets;

  const ImageRing({
    Key? key,
    required this.ring,
    required this.isSelected,
    required this.imageAssets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 400,
      child: Stack(
        children: [
          // Draw a base circle to represent the ring
          Center(
            child: Container(
              width: ring.innerRadius * 2 + ring.thickness * 2,
              height: ring.innerRadius * 2 + ring.thickness * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ring.baseColor.withOpacity(0.1), 
                  width: ring.thickness,
                ),
              ),
            ),
          ),
          // Position the images around the ring
          ...List.generate(imageAssets.length, (index) {
            final double totalAngle = 2 * math.pi;
            final double anglePerImage = totalAngle / imageAssets.length;
            final double angle = index * anglePerImage - math.pi / 2; // Start from top
            final double radius = ring.innerRadius + (ring.thickness / 2);
            final double imageSize = ring.thickness * 1.5;
            
            // Calculate position
            final double x = 200 + radius * math.cos(angle) - (imageSize / 2);
            final double y = 200 + radius * math.sin(angle) - (imageSize / 2);
            
            return Positioned(
              left: x,
              top: y,
              width: imageSize,
              height: imageSize,
              child: _buildImageWidget(imageAssets[index], imageSize),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildImageWidget(String assetPath, double size) {
    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => _buildPlaceholder(size),
      );
    } else {
      return Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(size),
      );
    }
  }
  
  Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.shade300 : Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  final Ring ring;
  final bool isSelected;
  final bool showLabels;

  RingPainter({
    required this.ring,
    required this.isSelected,
    this.showLabels = false,
  });

  // Generate a thematic color based on the base color and a percentage
  Color _getThematicColor(Color baseColor, double percentage) {
    try {
      // Create variations based on the base color
      if (percentage < 0.25) {
        // Lighter version
        return HSLColor.fromColor(baseColor).withLightness(
          (HSLColor.fromColor(baseColor).lightness + 0.2).clamp(0.0, 1.0)
        ).toColor();
      } else if (percentage < 0.5) {
        // Slightly lighter
        return HSLColor.fromColor(baseColor).withLightness(
          (HSLColor.fromColor(baseColor).lightness + 0.1).clamp(0.0, 1.0)
        ).toColor();
      } else if (percentage < 0.75) {
        // Slightly darker
        return HSLColor.fromColor(baseColor).withLightness(
          (HSLColor.fromColor(baseColor).lightness - 0.1).clamp(0.0, 1.0)
        ).toColor();
      } else {
        // Darker version
        return HSLColor.fromColor(baseColor).withLightness(
          (HSLColor.fromColor(baseColor).lightness - 0.2).clamp(0.0, 1.0)
        ).toColor();
      }
    } catch (e) {
      // Fallback to base color if any error occurs
      return baseColor;
    }
  }

  void _drawEraLabel(Canvas canvas, Offset center, String text, double angle, double radius, double sweepAngle) {
    if (!showLabels) return;
    
    final arcLength = sweepAngle * radius;
    if (arcLength < 20) return;

    double fontSize = 12.0;
    if (arcLength < 60) fontSize = 10.0;
    if (arcLength < 40) fontSize = 8.0;
    
    // Calculate percentage through the cycle for thematic coloring
    final percentage = angle / (2 * math.pi);
    
    // Get the background color (era color)
    final Color backgroundColor = _getThematicColor(ring.baseColor, percentage);
    
    // Calculate luminance to determine if the background is light or dark
    // Using the perceived brightness formula (0.299*R + 0.587*G + 0.114*B)
    final double luminance = (0.299 * backgroundColor.red + 
                             0.587 * backgroundColor.green + 
                             0.114 * backgroundColor.blue) / 255;
    
    // Choose text color based on background luminance
    // If luminance > 0.5, background is light, so use dark text
    final Color textColor = luminance > 0.5 ? Colors.black : Colors.white;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    String displayText = text;
    if (textPainter.width > arcLength * 0.8 && text.length > 5) {
      displayText = text.substring(0, 5) + '...';
      textPainter.text = TextSpan(
        text: displayText,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
    }

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
    _drawColorBasedRing(canvas, size, center);
    
    // Draw tick marks
    final tickPaint = Paint()
      ..color = isSelected 
          ? ring.baseColor.withOpacity(0.9) 
          : ring.baseColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 1.5 : 0.8;
    
    final tickLength = isSelected ? 6.0 : 4.0;
    
    // Draw fewer ticks for better performance
    final tickInterval = math.max(1, (ring.numberOfTicks / 60).ceil());
    
    for (int i = 0; i < ring.numberOfTicks; i += tickInterval) {
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

  void _drawColorBasedRing(Canvas canvas, Size size, Offset center) {
    // Draw eras
    for (var era in ring.eras) {
      try {
        final startAngle = (era.startDay * 2 * math.pi) / ring.numberOfTicks;
        final sweepAngle = ((era.endDay - era.startDay) * 2 * math.pi) / ring.numberOfTicks;
        
        // Ensure we have valid angles
        if (sweepAngle <= 0 || startAngle.isNaN || sweepAngle.isNaN) continue;
        
        // Calculate percentage through the cycle for thematic coloring
        final percentage = era.startDay / ring.numberOfTicks;
        
        // Use thematic color based on the ring's base color
        final Color eraColor = _getThematicColor(ring.baseColor, percentage);
        
        final eraPaint = Paint()
          ..color = eraColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = ring.thickness
          ..strokeCap = StrokeCap.round;
        
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
          sweepAngle,
        );
      } catch (e) {
        // Skip this era if there's an error
        continue;
      }
    }
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected || 
           oldDelegate.ring != ring || 
           oldDelegate.showLabels != showLabels;
  }
}