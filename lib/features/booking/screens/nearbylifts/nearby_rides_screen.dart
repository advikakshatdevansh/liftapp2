import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../data/models/ride_model.dart';
import '../../../../data/repository/ride_repository/ride_repository.dart';
import '../../../../data/repository/user_repository/user_repository.dart';
import '../../../../personalization/models/user_model.dart';
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
              final distance = ride.distanceKm;
              final price = (distance * 6).toStringAsFixed(2);

              // --- Nested FutureBuilder to Fetch User Details ---
              return FutureBuilder<UserModel>(
                // FIX APPLIED HERE: Using the correct, instantiated method
                future: UserRepository.instance.getUserById(ride.userId),
                // --------------------------------------------------------
                builder: (context, userSnapshot) {
                  // ... (rest of your builder logic remains the same)
                  final riderName = userSnapshot.data?.fullName ?? ride.riderName;
                  final profilePictureUrl = userSnapshot.data?.profilePicture;
                  final seats = ride.seatsAvailable;

                  // Show a loading shimmer or a simple card outline while fetching user data
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    // You can return a simplified Card with a Shimmer effect here
                    return const SizedBox(height: 100);
                  }

                  return Card(
                    elevation: 6, // Slightly higher shadow for visual depth
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Softer, more modern radius
                      side: BorderSide(
                        color: Colors.grey.shade700, // Very subtle border line
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- 1. RIDER INFO AND SEATS ---
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Dynamic Avatar
                              CircleAvatar(
                                radius: 30, // Slightly larger avatar
                                backgroundColor: Colors.deepPurple,
                                backgroundImage: (profilePictureUrl != null &&
                                    profilePictureUrl.isNotEmpty)
                                    ? NetworkImage(profilePictureUrl) as ImageProvider<Object>?
                                    : null,
                                child: (profilePictureUrl == null || profilePictureUrl.isEmpty)
                                    ? Text(
                                  riderName.isNotEmpty ? riderName[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18), // Increased font size for initials
                                )
                                    : null,
                              ),
                              const SizedBox(width: 20),

                              // Rider Name (Expanded)
                              Expanded(
                                child: Text(
                                  riderName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800, // Make name bolder
                                    color: Colors.white,
                                    fontSize: 20, // Slightly larger font size
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Seats Chip (Improved Visuals)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.shade50, // Light colored background
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.people_alt_outlined, size: 16, color: Colors.deepPurple),
                                    const SizedBox(width: 4),
                                    Text(
                                      "$seats seats",
                                      style: TextStyle(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 24, thickness: 1), // Clear visual separator

                          // --- 2. METRICS: DISTANCE & PRICE (Side-by-Side) ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Distance Metric
                              Expanded(
                                child: _MetricDetail(
                                  icon: Icons.route_outlined,
                                  label: "Trip Distance",
                                  value: "${distance.toStringAsFixed(1)} km",
                                  color: Colors.blueGrey,
                                ),
                              ),

                              const SizedBox(width: 10), // Add explicit spacing

                              // 2. Price Metric
                              Expanded(
                                child: _MetricDetail(
                                  icon: Icons.currency_rupee,
                                  label: "Estimated Cost",
                                  value: "₹${price.toString()}",
                                  color: Colors.green.shade700!,
                                ),
                              ),

                              const SizedBox(width: 10), // Add explicit spacing

                              // 3. Rating Metric
                              Expanded(
                                child: _MetricDetail(
                                  icon: Icons.star_border,
                                  label: "Rider Rating",
                                  value: "4.8", // Static example
                                  color: Colors.amber.shade700!,
                                ),
                              ),
                            ],
                          ),                          const SizedBox(height: 16),

                          // --- 3. ACTION BUTTON ---
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => RiderDetailsScreen(ride: ride));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,

                                padding: const EdgeInsets.symmetric(vertical: 10),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(48),
                                ),
                              ),
                              child: const Text(
                                "View & Request Lift",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                  },
              );
            },
          );
        },
      ),
    );
  }
}


class _MetricDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricDetail({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // NOTE: Removed the redundant 'Expanded' wrapper.
    // The parent Row must handle expansion for equal spacing.
    return Container(
      // --- WRAPPED CONTENT IN A DECORATED CONTAINER (Mini Card) ---
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08), // Light background tint
        borderRadius: BorderRadius.circular(8), // Rounded corners for the card
        border: Border.all(color: color.withOpacity(0.3), width: 0.5), // Subtle border
      ),
      // --- INNER CONTENT COLUMN ---
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // Use CrossAxisAlignment.center for vertical alignment within this row
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              // Label
              Expanded( // Ensures the label text wraps and doesn't push the card wider than needed
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600, // Slightly bolder label
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Value
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900, // Extra bold for key metrics
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}