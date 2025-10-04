import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:liftapp2/data/repository/lift_repository/lift_repository.dart';
import 'package:liftapp2/data/repository/notifications/authrepository.dart';
import 'package:liftapp2/features/booking/screens/viewRoute/widgets/google_map_widget.dart';
import 'package:liftapp2/features/booking/screens/viewRoute/widgets/select_vehicle_widget.dart';
import '../../../../data/models/lift_model.dart';
import '../../controllers/google_map_controller.dart';

class ViewRoute extends StatelessWidget {
  const ViewRoute({
    super.key,
    required this.source,
    required this.sourcename,
    required this.destination,
    required this.destinationname,
    required this.apiKey,
  });

  final LatLng source;
  final LatLng destination;
  final String apiKey;

  final sourcename;

  final destinationname;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomMap(source: source, destination: destination),
        PublishButton(
          onTap: () async {
            final controller = Get.find<CustomMapController>();
            final liftModel = LiftModel(
              userId: AuthenticationRepository.instance.getUserID,
              source: GeoPoint(source.latitude, source.longitude),
              destination: GeoPoint(
                destination.latitude,
                destination.longitude,
              ),
              sourceName: sourcename,
              destinationName: destinationname,
              distanceKm: controller.distance,
              createdAt: DateTime.now(),
              status: "looking",
            );
            await LiftRepository.instance.createLift(liftModel);
          },
        ),
      ],
    );
  }
}
