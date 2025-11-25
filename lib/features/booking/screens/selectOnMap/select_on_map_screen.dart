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
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              myLocationEnabled: true,

              initialCameraPosition: mapController.cameraPosition,
              onMapCreated: mapController.onMapCreated,
              onCameraMove: mapController.updateCameraPosition,

              myLocationButtonEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
            ),
            const Center(
              child: Icon(Icons.location_on, size: 50, color: Colors.red),
            ),
            Positioned(
              bottom: 90,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: mapController.selectLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .black, // Change 'Colors.teal' to your desired color
                  foregroundColor: Colors
                      .white, // Sets the color of the 'Select Location' text
                ),
                child: const Text('Select Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
