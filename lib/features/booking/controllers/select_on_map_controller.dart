import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectOnMapController extends GetxController {

  // Keep only ONE variable for the GoogleMapController
  late GoogleMapController mapController;

  late CameraPosition cameraPosition;

  void initCameraPosition(LatLng initialPosition, {double zoom = 15}) {
    cameraPosition = CameraPosition(target: initialPosition, zoom: zoom);
  }

  // Assign the created controller to the single mapController variable
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void updateCameraPosition(CameraPosition position) {
    cameraPosition = position;
  }

  void selectLocation() {
    Get.back(result: cameraPosition.target);
  }

  // Use the correctly initialized mapController for zooming
  void zoomIn() {
    mapController.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  // Use the correctly initialized mapController for zooming
  void zoomOut() {
    mapController.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }
}