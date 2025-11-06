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
                final ride = RideRepository.instance.createRide(
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
                  seatsAvailable: 3, // default, you can customize
                );
                Get.toNamed(TRoutes.activeLifts);
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
                final lift = LiftModel(
                  userId: AuthenticationRepository.instance.getUserID,
                  source: GeoPoint(source.latitude, source.longitude),
                  destination: GeoPoint(
                    destination.latitude,
                    destination.longitude,
                  ),
                  sourceName: sourcename,
                  destinationName: destinationname,
                  distanceKm: controller.distance.value,
                  createdAt: DateTime.now(),
                  status: "looking",
                );
                await LiftRepository.instance.createLift(lift);
                Get.toNamed(TRoutes.activeLifts);
              },
            )
          ],
        ),
      ),
    );
  }
}
