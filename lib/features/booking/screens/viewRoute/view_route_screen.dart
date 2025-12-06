import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:liftapp2/routes/app_routes.dart';
import '../../../../data/models/lift_model.dart';
import '../../../../data/models/ride_model.dart';
import '../../../../data/repository/lift_repository/lift_repository.dart';
import '../../../../data/repository/ride_repository/ride_repository.dart';
import '../../../../data/repository/notifications/authrepository.dart';
import '../../../../data/repository/user_repository/user_repository.dart';
import '../../controllers/google_map_controller.dart';
import 'widgets/google_map_widget.dart';
import 'widgets/select_vehicle_widget.dart';


class ViewRoute extends StatelessWidget {
  const ViewRoute({
    super.key,
    required this.source,
    required this.sourcename,
    required this.destination,
    required this.destinationname,
  });

  final LatLng source;
  final LatLng destination;
  final String sourcename;
  final String destinationname;

  @override
  Widget build(BuildContext context) {
    CustomMapController controller = Get.put(CustomMapController());

    // Define primary color for buttons
    final primaryColor = Theme
        .of(context)
        .primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Route"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          CustomMap(source: source, destination: destination),

          // --- ADD CUSTOM ZOOM BUTTONS HERE (Top Right) ---
          Positioned(
            top: 10,
            left: 10,
            child: Column(
              children: [
                // Zoom In Button
                FloatingActionButton.small(
                  heroTag: 'zoom_in_route',
                  // Unique hero tag required
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  onPressed: () => controller.zoomIn(),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                // Zoom Out Button
                FloatingActionButton.small(
                  heroTag: 'zoom_out_route',
                  // Unique hero tag required
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  onPressed: () => controller.zoomOut(),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
          // --- END CUSTOM ZOOM BUTTONS ---

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: PublishButton(
              source: source,
              destination: destination,
              onTap: () async {
                _showRideChoiceModal(context, controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ... (rest of the _showRideChoiceModal and _showSeatSelectionModal methods remain unchanged)
  void _showRideChoiceModal(BuildContext context,
      CustomMapController controller,) {
    // RideRepository.instance.addDummyRides();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.car_rental, color: Colors.green),
              title: const Text(
                "Give a Ride",
                style: TextStyle(
                  color: Colors.black, // Set the text color to black
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                _showSeatSelectionModal(context, controller);
                // Get.toNamed(TRoutes.activeLifts);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_search, color: Colors.blue),
              // Removed const from Text and added TextStyle with black color
              title: const Text(
                "Get a Lift",
                style: TextStyle(
                  color: Colors.black, // Set the text color to black
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final lift = await LiftRepository.instance.createLift(
                  userId: AuthenticationRepository.instance.getUserID,
                  lifterName: AuthenticationRepository.instance.getDisplayName,
                  source: LatLng(source.latitude, source.longitude),
                  destination: LatLng(
                    destination.latitude,
                    destination.longitude,
                  ),
                  sourceName: sourcename,
                  destinationName: destinationname,
                  distanceKm: controller.distance.value,
                  status: "looking",
                );
                // Get.toNamed(TRoutes.activeLifts);
                await controller.displayNearbyRides(
                  source: source,
                  destination: destination,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSeatSelectionModal(BuildContext context,
      CustomMapController controller,
      // Note: Assuming 'source', 'destination', 'sourcename', 'destinationname',
      // 'UserRepository', 'AuthenticationRepository', 'RideRepository', and 'TRoutes'
      // are available from the parent ViewRoute class scope.
      ) {
    int selectedSeats = 1;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          // Get the primary color dynamically for modern styling
          final primaryColor = Theme.of(context).primaryColor;

          return Container(
            // The container background outside the modal (usually transparent or theme color)
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15), // Slightly stronger shadow
                  blurRadius: 15,
                  offset: const Offset(0, -6),
                ),
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Handle Bar (Drag Indicator)
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // 2. Question Text
                const Text(
                  "How many seats are available?",
                  style: TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w700, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30), // Increased spacing for the selection area

                // 3. Seat Selection Row (Modern Look)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    int seat = index + 1;
                    bool isSelected = selectedSeats == seat;

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedSeats = seat);
                      },
                      child: AnimatedContainer( // Use AnimatedContainer for smooth transitions
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 6), // Reduced margin slightly
                        width: 60, // Slightly wider buttons
                        height: 70, // Taller buttons
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor // Use the strong primary color when selected
                              : Colors.grey.shade50, // Very light background when unselected
                          borderRadius: BorderRadius.circular(15), // Slightly larger radius
                          border: isSelected ? null : Border.all(color: Colors.grey.shade200, width: 1),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                              : [], // No shadow when unselected
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon to represent a seat
                            Icon(
                              Icons.event_seat_rounded,
                              size: 20,
                              color: isSelected ? Colors.white : Colors.black54,
                            ),
                            const SizedBox(height: 4),
                            // Seat Number
                            Text(
                              seat.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40), // More space before the main button

                // 4. Publish Button (Main Action)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, // Use Primary color for the main action
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () async {
                    Navigator.pop(context); // close modal

                    // --- Business Logic (Unchanged) ---
                    final user = await UserRepository.instance.getUserById(
                      AuthenticationRepository.instance.getUserID,
                    );

                    await RideRepository.instance.createRide(
                      userId: AuthenticationRepository.instance.getUserID,
                      source: LatLng(source.latitude, source.longitude),
                      destination: LatLng(
                        destination.latitude,
                        destination.longitude,
                      ),
                      sourceName: sourcename,
                      destinationName: destinationname,
                      distanceKm: controller.distance.value,
                      status: "active",
                      seatsAvailable: selectedSeats,
                    );

                    await controller.displayNearbyLifts(
                      source: source,
                      destination: destination,
                    );

                    Get.snackbar(
                      "Ride Published",
                      "Your ride has been successfully created!",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    );

                    Get.offAllNamed(TRoutes.home);
                  },
                  child: const Text(
                    "Publish Ride",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );  }
}