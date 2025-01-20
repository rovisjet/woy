class CircleModel {
  final String name;
  final String description;
  final double daysInCycle;
  final bool repeats;
  final String baseColor;

  CircleModel({
    required this.name,
    required this.description,
    required this.daysInCycle,
    required this.repeats,
    this.baseColor = "#0000FF",
  });
}