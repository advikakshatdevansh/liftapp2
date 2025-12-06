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

    return Stack(
      children: [
        CustomMap(source: source, destination: destination),
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
    );
  }

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
    int selectedSeats = 1;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
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

                const Text(
                  "How many seats are available?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Seat Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    int seat = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedSeats = seat);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedSeats == seat
                              ? Colors.green
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          seat.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);

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
                      seatsAvailable: selectedSeats, // 👈 SET SEATS HERE
                    );

                    await controller.displayNearbyLifts(
                      source: source,
                      destination: destination,
                    );
                  },
                  child: const Text(
                    "Publish Ride",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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

    // 👇 REDIRECT TO HOME SCREEN
    Get.offAllNamed(TRoutes.home);
  }
}
