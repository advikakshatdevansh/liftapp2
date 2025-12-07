import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/ride_model.dart';
import '../../controllers/nearbyRides_controller.dart';

class RiderDetailsScreen extends StatelessWidget {
  final RideModel ride;

  const RiderDetailsScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RiderDetailsController(ride));

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          appBar: AppBar(title: const Text("Rider Details")),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.user.value == null) {
        return Scaffold(
          appBar: AppBar(title: const Text("Rider Details")),
          body: const Center(child: Text("Error loading rider")),
        );
      }

      final user = controller.user.value!;

      return Scaffold(
        appBar: AppBar(title: const Text("Rider Details")),
          body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              /// PROFILE CARD
              Card(
                elevation: 0,
                color: Colors.black, // Example: Set to a very light gray
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: user.profilePicture.isNotEmpty
                            ? NetworkImage(user.profilePicture)
                            : null,
                        child: user.profilePicture.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Chip(
                        label: Text(user.verificationStatus.name),
                        avatar: Icon(
                          user.verificationStatus.name == 'verified'
                              ? Icons.check_circle
                              : Icons.warning,
                          color: user.verificationStatus.name == 'verified'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        backgroundColor:
                            user.verificationStatus.name == 'verified'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                      ),
                    ],
                  ),
                ),
              ),
              /// CONTACT BUTTONS
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.callUser(user.phoneNumber),
                      icon: const Icon(Icons.call),
                      label: const Text("Call"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        // --- FIX 1: Set text/icon color to white ---
                        foregroundColor: Colors.white,
                        // --- FIX 2: Remove border/shadow ---
                        elevation: 0,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40), // Adjust the value (e.g., 8, 12, 40) as needed
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.messageUser,
                      icon: const Icon(Icons.message),
                      label: const Text("Message"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        // --- FIX 1: Set text/icon color to white ---
                        foregroundColor: Colors.white,
                        elevation: 0,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40), // Adjust the value (e.g., 8, 12, 40) as needed
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// TRIP SUMMARY
              Card(
                elevation: 2,
                color: Colors.black, // Example: Set to a very light gray

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: Colors.grey.shade800, // A light border color
                    width: 1.0,                    // A thin border width
                  ),
                ),


                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text("Departure Time"),
                      subtitle: Text(
                        controller.formattedRideTime,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text("From"),
                      subtitle: Text(controller.ride.sourceName),
                    ),
                    ListTile(
                      leading: const Icon(Icons.pin_drop),
                      title: const Text("To"),
                      subtitle: Text(controller.ride.destinationName),
                    ),
                    ListTile(
                      leading: const Icon(Icons.timeline),
                      title: const Text("Distance"),
                      trailing: Text(
                        "${controller.ride.distanceKm.toStringAsFixed(2)} Km",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.currency_rupee),
                      title: const Text("Estimated Price"),
                      trailing: Text(
                        "₹${(controller.ride.distanceKm * 6).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// REQUEST LIFT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.requestLift,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    foregroundColor: Colors.white,
                    elevation: 0.0,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Adjust the value (e.g., 8, 12, 40) as needed
                    ),
                  ),
                  child: const Text(
                    "Request Lift",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
          )
      );
    });
  }
}
