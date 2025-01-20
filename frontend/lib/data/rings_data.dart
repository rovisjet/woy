import 'package:flutter/material.dart';
import '../models/ring_model.dart';
import '../models/era_model.dart';

class RingsData {
  static List<Ring> rings = [
    Ring(
      index: 0,
      name: 'Menstrual Cycle',
      innerRadius: 60,
      thickness: 40,
      numberOfTicks: 28,
      baseColor: Colors.pink,
      eras: [
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
      ],
    ),
    Ring(
      index: 1,
      name: 'Moon Cycle',
      innerRadius: 110,
      thickness: 40,
      numberOfTicks: 29,
      baseColor: Colors.blue,
      eras: [
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
          endDay: 7.2,
          color: Colors.blue.shade400,
        ),
        Era(
          name: 'First Quarter',
          description: 'First Quarter phase',
          startDay: 7.2,
          endDay: 10.8,
          color: Colors.blue.shade500,
        ),
        Era(
          name: 'Waxing Gibbous',
          description: 'Waxing Gibbous phase',
          startDay: 10.8,
          endDay: 14.5,
          color: Colors.blue.shade600,
        ),
        Era(
          name: 'Full Moon',
          description: 'Full Moon phase',
          startDay: 14.5,
          endDay: 18.1,
          color: Colors.blue.shade700,
        ),
        Era(
          name: 'Waning Gibbous',
          description: 'Waning Gibbous phase',
          startDay: 18.1,
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
      ],
    ),
    Ring(
      index: 2,
      name: 'Year',
      innerRadius: 160,
      thickness: 40,
      numberOfTicks: 365,
      baseColor: Colors.green,
      eras: [
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
      ],
    ),
  ];
} 