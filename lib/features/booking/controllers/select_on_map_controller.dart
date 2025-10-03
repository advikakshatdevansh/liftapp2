import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectOnMapController extends GetxController {
  late GoogleMapController mapController;

  late CameraPosition cameraPosition;

  void initCameraPosition(LatLng initialPosition, {double zoom = 15}) {
    cameraPosition = CameraPosition(target: initialPosition, zoom: zoom);
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void updateCameraPosition(CameraPosition position) {
    cameraPosition = position;
  }

  void selectLocation() {
    Get.back(result: cameraPosition.target);
  }
}
