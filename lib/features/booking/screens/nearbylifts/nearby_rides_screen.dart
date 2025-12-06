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
                        crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically in the center
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
                              // Ensures long names wrap or truncate nicely
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8), // Add a small space between name and chip
                          Chip(
                            label: Text("$seats seats"),
                            backgroundColor: Colors.white,
                            // Use labelStyle to control the text appearance (color, font size, etc.)
                            labelStyle: const TextStyle(
                              color: Colors.black, // <-- Set the text color here
                            ),
                            side: BorderSide.none,
                            elevation: 0,
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

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => RiderDetailsScreen(ride: ride));
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            side: BorderSide.none,
                            elevation: 0,
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
