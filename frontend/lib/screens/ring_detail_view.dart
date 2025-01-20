import 'package:flutter/material.dart';
import '../models/ring_model.dart';
import '../models/era_model.dart';
import '../widgets/daily_snapshot_modal.dart';  // for EventCard

class RingDetailView extends StatelessWidget {
  final Ring ring;

  const RingDetailView({
    Key? key,
    required this.ring,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          ring.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Phases Section
          const Text(
            'Phases',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...ring.eras.map((era) => EraCard(era: era)).toList(),
          
          const SizedBox(height: 32),
          
          // Events Section
          const Text(
            'Events',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...ring.events.map((event) => EventCard(event: event)).toList(),
        ],
      ),
    );
  }
}

class EraCard extends StatelessWidget {
  final Era era;

  const EraCard({Key? key, required this.era}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: era.color.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              era.name,
              style: TextStyle(
                color: era.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Days ${era.startDay.toInt()} - ${era.endDay.toInt()}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            if (era.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                era.description,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 