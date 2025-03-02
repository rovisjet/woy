import 'package:flutter/material.dart';
import '../models/ring_model.dart';
import 'ring_detail_view.dart';
import '../data/rings_data.dart';

class RingListView extends StatefulWidget {
  const RingListView({Key? key}) : super(key: key);

  @override
  State<RingListView> createState() => _RingListViewState();
}

class _RingListViewState extends State<RingListView> {
  List<Ring> rings = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Initially use the static rings data
    rings = RingsData.rings;
    // Then fetch from API
    _fetchRings();
  }

  Future<void> _fetchRings() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
      
      final fetchedRings = await RingsData.fetchRings();
      
      setState(() {
        rings = fetchedRings;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching rings: $e');
      setState(() {
        errorMessage = 'Failed to load rings: $e';
        isLoading = false;
      });
    }
  }

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
        title: const Text(
          'Rings',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchRings,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchRings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rings.length,
                  itemBuilder: (context, index) {
                    final ring = rings[index];
                    return RingCard(
                      ring: ring,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RingDetailView(ring: ring),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class RingCard extends StatelessWidget {
  final Ring ring;
  final VoidCallback onTap;

  const RingCard({
    Key? key,
    required this.ring,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[900],
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: ring.baseColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ring.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${ring.numberOfTicks} days',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 