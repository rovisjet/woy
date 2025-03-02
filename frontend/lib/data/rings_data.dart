import 'package:flutter/material.dart';
import '../models/ring_model.dart';
import '../models/era_model.dart';
import '../services/api_service.dart';

class RingsData {
  static const double CANVAS_SIZE = 400.0;
  static const double CENTER_CIRCLE_RADIUS = 50.0;
  static const double DEFAULT_THICKNESS = 20.0; // Slightly thinner rings
  static const double RING_SPACING = 10.0; // Add spacing between rings

  static double _calculateInnerRadius(int ringIndex, int totalRings) {
    // Available space is from center circle to edge of canvas
    double availableSpace = (CANVAS_SIZE / 2) - CENTER_CIRCLE_RADIUS;
    // Total space needed for all rings and gaps
    double totalRingSpace = (totalRings * DEFAULT_THICKNESS) + ((totalRings - 1) * RING_SPACING);
    // Scale factor to fit everything
    double scaleFactor = availableSpace / totalRingSpace;
    
    // Calculate inner radius with spacing
    double innerRadius = CENTER_CIRCLE_RADIUS;
    for (int i = 0; i < ringIndex; i++) {
      innerRadius += (DEFAULT_THICKNESS * scaleFactor) + (RING_SPACING * scaleFactor);
    }
    
    return innerRadius;
  }

  // Static rings list for backward compatibility during transition
  static List<Ring> rings = _getFallbackRings();
  
  // Method to fetch rings from API
  static Future<List<Ring>> fetchRings() async {
    try {
      final fetchedRings = await ApiService.fetchRings();
      
      // Update the inner radius based on the count of rings
      final processedRings = _updateRingRadii(fetchedRings);
      
      // Update the static rings list
      rings = processedRings;
      
      return processedRings;
    } catch (e) {
      print('Error fetching rings from API: $e');
      // Fall back to hard-coded data
      return _getFallbackRings();
    }
  }
  
  // Update inner radii of rings based on their count
  static List<Ring> _updateRingRadii(List<Ring> fetchedRings) {
    final int totalRings = fetchedRings.length;
    
    return fetchedRings.map((ring) {
      return Ring(
        index: ring.index,
        name: ring.name,
        innerRadius: _calculateInnerRadius(ring.index, totalRings),
        thickness: DEFAULT_THICKNESS,
        numberOfTicks: ring.numberOfTicks,
        baseColor: ring.baseColor,
        eras: ring.eras,
        useImages: ring.useImages,
        imageAssets: ring.imageAssets,
        events: ring.events,
      );
    }).toList();
  }

  // Fallback data for when the API is unavailable
  static List<Ring> _getFallbackRings() {
    final ringConfigs = [
      _RingConfig('Menstrual Cycle', 28, Colors.pink, _menstrualEras()),
      _RingConfig('Moon Cycle', 29, Colors.blue, _moonEras()),
      _ImageRingConfig('Moon Phases', 8, Colors.blue, _moonPhaseImages()),
      _RingConfig('Year', 365, Colors.green, _yearEras()),
      _RingConfig('Chinese Elements', 60, Colors.brown, _elementEras()),
      _RingConfig('Planetary Houses', 12, Colors.deepPurple, _houseEras()),
      _RingConfig('Ocean Tides', 12, Colors.cyan, _tideEras()),
      _RingConfig('Crop Cycle', 120, Colors.lightGreen, _cropEras()),
      _RingConfig('Butterfly Life', 40, Colors.lime, _butterflyEras()),
    ];

    return List.generate(ringConfigs.length, (index) {
      final config = ringConfigs[index];
      
      // Handle both types of ring configurations
      String name = '';
      int ticks = 0;
      Color color = Colors.grey;
      
      if (config is _ImageRingConfig) {
        name = config.name;
        ticks = config.ticks;
        color = config.color;
        
        return Ring(
          index: index,
          name: name,
          innerRadius: _calculateInnerRadius(index, ringConfigs.length),
          thickness: DEFAULT_THICKNESS,
          numberOfTicks: ticks,
          baseColor: color,
          useImages: true,
          imageAssets: config.images,
        );
      } else if (config is _RingConfig) {
        name = config.name;
        ticks = config.ticks;
        color = config.color;
        
        return Ring(
          index: index,
          name: name,
          innerRadius: _calculateInnerRadius(index, ringConfigs.length),
          thickness: DEFAULT_THICKNESS,
          numberOfTicks: ticks,
          baseColor: color,
          eras: config.eras,
        );
      } else {
        throw Exception('Unsupported ring configuration type');
      }
    });
  }

  static List<String> _moonPhaseImages() => [
    'assets/images/moon/new_moon.svg',
    'assets/images/moon/waxing_crescent.svg',
    'assets/images/moon/first_quarter.svg',
    'assets/images/moon/waxing_gibbous.svg',
    'assets/images/moon/full_moon.svg',
    'assets/images/moon/waning_gibbous.svg',
    'assets/images/moon/last_quarter.svg',
    'assets/images/moon/waning_crescent.svg',
  ];

  static List<Era> _menstrualEras() => [
    Era(
      name: 'Menstrual',
      description: 'Menstrual phase',
      startDay: 0,
      endDay: 5,
      color: Colors.pink.shade300,
    ),
    Era(
      name: 'Follicular',
      description: 'Follicular phase',
      startDay: 5,
      endDay: 14,
      color: Colors.pink.shade400,
    ),
    Era(
      name: 'Ovulation',
      description: 'Ovulation phase',
      startDay: 14,
      endDay: 16,
      color: Colors.pink.shade500,
    ),
    Era(
      name: 'Luteal',
      description: 'Luteal phase',
      startDay: 16,
      endDay: 28,
      color: Colors.pink.shade600,
    ),
  ];

  static List<Era> _moonEras() => [
    Era(
      name: 'New Moon',
      description: 'New Moon phase',
      startDay: 0,
      endDay: 3.6,
      color: Colors.blue.shade300,
    ),
    Era(
      name: 'Waxing Crescent',
      description: 'Waxing Crescent phase',
      startDay: 3.6,
      endDay: 7.4,
      color: Colors.blue.shade400,
    ),
    Era(
      name: 'First Quarter',
      description: 'First Quarter phase',
      startDay: 7.4,
      endDay: 11.1,
      color: Colors.blue.shade500,
    ),
    Era(
      name: 'Waxing Gibbous',
      description: 'Waxing Gibbous phase',
      startDay: 11.1,
      endDay: 14.8,
      color: Colors.blue.shade600,
    ),
    Era(
      name: 'Full Moon',
      description: 'Full Moon phase',
      startDay: 14.8,
      endDay: 18.5,
      color: Colors.blue.shade700,
    ),
    Era(
      name: 'Waning Gibbous',
      description: 'Waning Gibbous phase',
      startDay: 18.5,
      endDay: 21.7,
      color: Colors.blue.shade600,
    ),
    Era(
      name: 'Last Quarter',
      description: 'Last Quarter phase',
      startDay: 21.7,
      endDay: 25.3,
      color: Colors.blue.shade500,
    ),
    Era(
      name: 'Waning Crescent',
      description: 'Waning Crescent phase',
      startDay: 25.3,
      endDay: 29,
      color: Colors.blue.shade400,
    ),
  ];

  static List<Era> _yearEras() => [
    Era(
      name: 'Spring',
      description: 'Spring season',
      startDay: 0,
      endDay: 91.25,
      color: Colors.green.shade300,
    ),
    Era(
      name: 'Summer',
      description: 'Summer season',
      startDay: 91.25,
      endDay: 182.5,
      color: Colors.green.shade400,
    ),
    Era(
      name: 'Fall',
      description: 'Fall season',
      startDay: 182.5,
      endDay: 273.75,
      color: Colors.green.shade500,
    ),
    Era(
      name: 'Winter',
      description: 'Winter season',
      startDay: 273.75,
      endDay: 365,
      color: Colors.green.shade600,
    ),
  ];

  static List<Era> _elementEras() => [
    Era(
      name: 'Wood',
      description: 'Growth & Flexibility',
      startDay: 0,
      endDay: 12,
      color: Colors.green.shade800,
    ),
    Era(
      name: 'Fire',
      description: 'Energy & Transformation',
      startDay: 12,
      endDay: 24,
      color: Colors.deepOrange.shade600,
    ),
    Era(
      name: 'Earth',
      description: 'Stability & Nourishment',
      startDay: 24,
      endDay: 36,
      color: Colors.brown.shade400,
    ),
    Era(
      name: 'Metal',
      description: 'Clarity & Precision',
      startDay: 36,
      endDay: 48,
      color: Colors.grey.shade400,
    ),
    Era(
      name: 'Water',
      description: 'Wisdom & Adaptability',
      startDay: 48,
      endDay: 60,
      color: Colors.blue.shade800,
    ),
  ];

  static List<Era> _houseEras() => [
    Era(
      name: '1st House',
      description: 'Self & Identity',
      startDay: 0,
      endDay: 1,
      color: Colors.deepPurple.shade300,
    ),
    Era(
      name: '2nd House',
      description: 'Values & Possessions',
      startDay: 1,
      endDay: 2,
      color: Colors.deepPurple.shade400,
    ),
    Era(
      name: '3rd House',
      description: 'Communication',
      startDay: 2,
      endDay: 3,
      color: Colors.deepPurple.shade500,
    ),
    Era(
      name: '4th House',
      description: 'Home & Family',
      startDay: 3,
      endDay: 4,
      color: Colors.deepPurple.shade600,
    ),
    Era(
      name: '5th House',
      description: 'Creativity & Pleasure',
      startDay: 4,
      endDay: 5,
      color: Colors.deepPurple.shade700,
    ),
    Era(
      name: '6th House',
      description: 'Work & Health',
      startDay: 5,
      endDay: 6,
      color: Colors.deepPurple.shade800,
    ),
    Era(
      name: '7th House',
      description: 'Relationships',
      startDay: 6,
      endDay: 7,
      color: Colors.deepPurple.shade300,
    ),
    Era(
      name: '8th House',
      description: 'Transformation',
      startDay: 7,
      endDay: 8,
      color: Colors.deepPurple.shade400,
    ),
    Era(
      name: '9th House',
      description: 'Philosophy & Travel',
      startDay: 8,
      endDay: 9,
      color: Colors.deepPurple.shade500,
    ),
    Era(
      name: '10th House',
      description: 'Career & Status',
      startDay: 9,
      endDay: 10,
      color: Colors.deepPurple.shade600,
    ),
    Era(
      name: '11th House',
      description: 'Friends & Goals',
      startDay: 10,
      endDay: 11,
      color: Colors.deepPurple.shade700,
    ),
    Era(
      name: '12th House',
      description: 'Spirituality',
      startDay: 11,
      endDay: 12,
      color: Colors.deepPurple.shade800,
    ),
  ];

  static List<Era> _tideEras() => [
    Era(
      name: 'High Tide',
      description: 'Peak water level',
      startDay: 0,
      endDay: 3,
      color: Colors.cyan.shade700,
    ),
    Era(
      name: 'Ebb Tide',
      description: 'Receding waters',
      startDay: 3,
      endDay: 6,
      color: Colors.cyan.shade500,
    ),
    Era(
      name: 'Low Tide',
      description: 'Minimum water level',
      startDay: 6,
      endDay: 9,
      color: Colors.cyan.shade300,
    ),
    Era(
      name: 'Flood Tide',
      description: 'Rising waters',
      startDay: 9,
      endDay: 12,
      color: Colors.cyan.shade600,
    ),
  ];

  static List<Era> _cropEras() => [
    Era(
      name: 'Preparation',
      description: 'Soil preparation',
      startDay: 0,
      endDay: 15,
      color: Colors.brown.shade300,
    ),
    Era(
      name: 'Planting',
      description: 'Seed sowing',
      startDay: 15,
      endDay: 30,
      color: Colors.lightGreen.shade300,
    ),
    Era(
      name: 'Growth',
      description: 'Plant development',
      startDay: 30,
      endDay: 75,
      color: Colors.lightGreen.shade600,
    ),
    Era(
      name: 'Harvest',
      description: 'Crop collection',
      startDay: 75,
      endDay: 90,
      color: Colors.yellow.shade600,
    ),
    Era(
      name: 'Fallow',
      description: 'Rest period',
      startDay: 90,
      endDay: 120,
      color: Colors.brown.shade200,
    ),
  ];

  static List<Era> _butterflyEras() => [
    Era(
      name: 'Egg',
      description: 'Initial stage',
      startDay: 0,
      endDay: 5,
      color: Colors.white70,
    ),
    Era(
      name: 'Caterpillar',
      description: 'Larval stage',
      startDay: 5,
      endDay: 20,
      color: Colors.lime.shade400,
    ),
    Era(
      name: 'Chrysalis',
      description: 'Pupa stage',
      startDay: 20,
      endDay: 35,
      color: Colors.teal.shade300,
    ),
    Era(
      name: 'Butterfly',
      description: 'Adult stage',
      startDay: 35,
      endDay: 40,
      color: Colors.orange.shade300,
    ),
  ];
}

class _RingConfig {
  final String name;
  final int ticks;
  final Color color;
  final List<Era> eras;

  _RingConfig(this.name, this.ticks, this.color, this.eras);
}

class _ImageRingConfig {
  final String name;
  final int ticks;
  final Color color;
  final List<String> images;

  _ImageRingConfig(this.name, this.ticks, this.color, this.images);
} 