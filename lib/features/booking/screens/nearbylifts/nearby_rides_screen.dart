import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../data/models/ride_model.dart';
import '../../../../data/repository/ride_repository/ride_repository.dart';
import '../riderdetails/riderdetails_screen.dart';

class NearbyRidesScreen extends StatelessWidget {
  final LatLng source;
  final LatLng destination;

  const NearbyRidesScreen({
    super.key,
    required this.source,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Rides Nearby"),
        centerTitle: true,
      ),

      body: FutureBuilder<List<RideModel>>(
        future: RideRepository.instance.findRides(
          source: source,
          destination: destination,
          radius: 5,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rides = snapshot.data!;

          if (rides.isEmpty) {
            return const Center(
              child: Text(
                "No rides available nearby.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: rides.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final ride = rides[index];
              final riderName = ride.userId;
              final seats = ride.seatsAvailable;
              final distance = ride.distanceKm;
              final price = (distance * 6).toStringAsFixed(2);

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.deepPurple,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              riderName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text("$seats seats"),
                            backgroundColor: Colors.green.shade100,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(Icons.route, size: 18),
                          const SizedBox(width: 6),
                          Text("${distance.toStringAsFixed(1)} km"),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.currency_rupee, size: 18),
                          const SizedBox(width: 6),
                          Text(price),
                        ],
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => RiderDetailsScreen(ride: ride));
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Request Lift"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
