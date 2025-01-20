import 'package:flutter/material.dart';

class Era {
  final String name;
  final String description;
  final double startDay;
  final double endDay;
  final Color color;

  Era({
    required this.name,
    required this.description,
    required this.startDay,
    required this.endDay,
    required this.color,
  });
}