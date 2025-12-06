import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../data/models/ride_model.dart';
import '../../../../data/repository/ride_repository/ride_repository.dart';

class NearbyRidesController extends GetxController {
  final LatLng source;
  final LatLng destination;

  NearbyRidesController({required this.source, required this.destination});

  // Observables
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = "".obs;

  RxList<RideModel> rides = <RideModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNearbyRides();
  }

  /// Fetch rides near the selected source & destination
  Future<void> fetchNearbyRides() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final fetchedRides = await RideRepository.instance.findRides(
        source: source,
        destination: destination,
      );

      rides.assignAll(fetchedRides);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
