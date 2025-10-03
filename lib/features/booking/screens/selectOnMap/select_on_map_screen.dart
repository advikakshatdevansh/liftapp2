import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/select_on_map_controller.dart';

class SelectOnMap extends StatelessWidget {
  final LatLng currentPosition;

  const SelectOnMap({super.key, required this.currentPosition});

  @override
  Widget build(BuildContext context) {
    final mapController = Get.put(SelectOnMapController());
    mapController.initCameraPosition(currentPosition);
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: mapController.cameraPosition,
            onMapCreated: mapController.onMapCreated,
            onCameraMove: mapController.updateCameraPosition,
          ),
          const Center(
            child: Icon(Icons.location_on, size: 50, color: Colors.red),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: mapController.selectLocation,
              child: const Text('Select Location'),
            ),
          ),
        ],
      ),
    );
  }
}
