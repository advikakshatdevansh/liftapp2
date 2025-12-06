import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // Import this for better date formatting

import '../../../../data/models/ride_model.dart';
import '../../../../data/repository/user_repository/user_repository.dart';
import '../../../../personalization/models/user_model.dart';
import 'package:intl/intl.dart'; // <-- Add this import
class RiderDetailsScreen extends StatelessWidget {
  final RideModel ride;

  const RiderDetailsScreen({super.key, required this.ride});

  Future<void> callUser(String phoneNumber) async {
    final Uri uri = Uri(scheme: "tel", path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("Error", "Unable to open dialer");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Helper to format the time clearly
    final rideTime = DateFormat('EEE, MMM d, yyyy \n hh:mm a').format(ride.createdAt);    return FutureBuilder<UserModel>(
      future: UserRepository.instance.getUserById(ride.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text("Rider Details")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text("Rider Details")),
            body: Center(child: Text("Error fetching user data: ${snapshot.error ?? 'Unknown error'}")),
          );
        }

        final user = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: const Text("Rider Details")),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Rider Profile Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.deepPurple.withOpacity(0.1),
                          backgroundImage: user.profilePicture.isNotEmpty
                              ? NetworkImage(user.profilePicture)
                              : null,
                          child: user.profilePicture.isEmpty
                              ? const Icon(Icons.person, size: 40, color: Colors.deepPurple)
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        // Verification Chip
                        Chip(
                          label: Text(user.verificationStatus.name),
                          avatar: Icon(
                            user.verificationStatus.name == 'verified' ? Icons.check_circle : Icons.warning,
                            color: user.verificationStatus.name == 'verified' ? Colors.green : Colors.orange,
                            size: 18,
                          ),
                          backgroundColor: user.verificationStatus.name == 'verified' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: user.verificationStatus.name == 'verified' ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Contact Buttons (Keep existing Row for good spacing)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => callUser(user.phoneNumber),
                        icon: const Icon(Icons.call_rounded),
                        label: const Text("Call"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Added shape
                          elevation: 2, // Added slight elevation back for action
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.snackbar(
                            "Coming soon",
                            "Chat feature will be added.",
                          );
                        },
                        icon: const Icon(Icons.message_rounded),
                        label: const Text("Message"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Added shape
                          elevation: 2, // Added slight elevation back for action
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Ride Details Section using ListTiles
                Text(
                  "📍 Trip Summary",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.schedule, color: Colors.blueGrey),
                        title: const Text("Departure Time"),
                        subtitle: Text(rideTime, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.green),
                        title: const Text("From"),
                        subtitle: Text(ride.sourceName),
                      ),
                      ListTile(
                        leading: const Icon(Icons.pin_drop, color: Colors.red),
                        title: const Text("To"),
                        subtitle: Text(ride.destinationName),
                      ),
                      ListTile(
                        leading: const Icon(Icons.timeline, color: Colors.teal),
                        title: const Text("Distance"),
                        trailing: Text("${ride.distanceKm} Km", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.currency_rupee_rounded, color: Colors.orange),
                        title: const Text("Estimated Price"),
                        trailing: Text("₹${(ride.distanceKm * 6).toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 4. Request Lift button (Primary Action)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar(
                        "Request Sent",
                        "Your request has been sent to ${user.fullName}",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Increased radius for primary
                      elevation: 5, // A clear elevation for the main action
                    ),
                    child: const Text(
                      "Request Lift",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}