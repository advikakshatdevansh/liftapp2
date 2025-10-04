import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:liftapp2/features/booking/controllers/google_map_controller.dart';

class CustomMap extends StatelessWidget {
  const CustomMap({super.key, required this.source, required this.destination});

  final LatLng source;
  final LatLng destination;

  @override
  Widget build(BuildContext context) {
    // Put controller
    final controller = Get.find<CustomMapController>();

    // Add markers once (avoid duplicates)
    if (controller.markers.isEmpty) {
      controller.addMarkers(source: source, destination: destination);
    }

    // Reactive GoogleMap
    return Obx(
      () => GoogleMap(
        initialCameraPosition: CameraPosition(target: source, zoom: 12),
        markers: Set<Marker>.of(controller.markers),
        polylines: Set<Polyline>.of(controller.polylines),
        onMapCreated: controller.onMapCreated,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
