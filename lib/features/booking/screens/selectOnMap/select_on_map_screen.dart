import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/select_on_map_controller.dart';

class SelectOnMap extends StatelessWidget {
  final LatLng currentPosition;

  const SelectOnMap({super.key, required this.currentPosition});

  @override
  Widget build(BuildContext context) {
    // Use Get.find if controller is guaranteed to exist from a parent binding
    // otherwise Get.put is fine, but Get.find is generally cleaner in the build method.
    final mapController = Get.put(SelectOnMapController());
    mapController.initCameraPosition(currentPosition);

    // Define consistent styling for the custom buttons
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Removed SafeArea since the map is full-screen and we control the UI elements
      body: Stack(
        children: [
          // 1. Google Map (with Native Zoom Controls Disabled)
          GoogleMap(
            myLocationEnabled: true,
            initialCameraPosition: mapController.cameraPosition,
            onMapCreated: mapController.onMapCreated,
            onCameraMove: mapController.updateCameraPosition,

            // --- KEY CHANGE: Disable native zoom controls ---
            zoomControlsEnabled: false,
            // -------------------------------------------------

            myLocationButtonEnabled: true,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
          ),

          // Center pin icon
          const Center(
            child: Icon(Icons.location_on, size: 50, color: Colors.red),
          ),

          // 2. Custom Zoom Buttons (Top Left)
          Positioned(
            top: 10,
            left: 10,
            child: Column(
              children: [
                // Zoom In Button
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  onPressed: () => mapController.zoomIn(), // You need to implement this in your controller
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                // Zoom Out Button
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  onPressed: () => mapController.zoomOut(), // You need to implement this in your controller
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          // 3. Select Location Button (Bottom)
          Positioned(
            bottom: 30, // Adjusted for cleaner bottom margin outside SafeArea
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: mapController.selectLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Select Location'),
            ),
          ),
        ],
      ),
    );
  }
}