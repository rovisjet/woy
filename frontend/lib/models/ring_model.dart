import 'package:flutter/material.dart';
import 'era_model.dart';

class Ring {
  final int index;
  final String name;
  final double innerRadius;
  final double thickness;
  final int numberOfTicks;
  final Color baseColor;
  final List<Era> eras;
  final List<dynamic> events;

  const Ring({
    required this.index,
    required this.name,
    required this.innerRadius,
    required this.thickness,
    required this.numberOfTicks,
    required this.baseColor,
    this.eras = const [],
    this.events = const [],
  });
} 