import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:liftapp2/routes/app_routes.dart';
import '../../../../data/repository/lift_repository/lift_repository.dart';
import '../../../../data/repository/ride_repository/ride_repository.dart';
import '../../../../data/repository/notifications/authrepository.dart';
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
    final primaryColor = Theme.of(context).primaryColor;

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
  void _showRideChoiceModal(
    BuildContext context,
    CustomMapController controller,
  ) {
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

  void _showSeatSelectionModal(
    BuildContext context,
    CustomMapController controller,
  ) {
    int selectedSeats = 1; // default selected seat

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          final primaryColor = Theme.of(context).primaryColor;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
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

                // Title
                const Text(
                  "How many seats are available?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Seat selection row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final seat = index + 1;
                    final isSelected = seat == selectedSeats;

                    return GestureDetector(
                      onTap: () => setState(() => selectedSeats = seat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_seat_rounded,
                              color: isSelected ? Colors.white : Colors.black54,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              seat.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 30),

                // Publish Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context); // close modal

                    await RideRepository.instance.createRide(
                      userId: AuthenticationRepository.instance.getUserID,
                      source: source,
                      destination: destination,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}
