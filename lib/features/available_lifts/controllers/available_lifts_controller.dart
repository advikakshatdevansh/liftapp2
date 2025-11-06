// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../../../../data/repository/ride_repository/ride_repository.dart';
// import '../../../../data/models/ride_model.dart';
//
// class AvailableLiftsController extends GetxController {
//   static AvailableLiftsController get instance => Get.find();
//
//   final rides = <RideModel>[].obs;
//   final isLoading = false.obs;
//
//   /// Fetch available rides near a given source/destination
//   Future<void> fetchAvailableRides({
//     required LatLng source,
//     required LatLng destination,
//     double radius = 10.0, // km
//   }) async {
//     try {
//       isLoading.value = true;
//       final rideRepository = RideRepository.instance;
//
//       // 🔍 Get rides near source & destination
//       final ridesRef = await rideRepository.findRides(
//         source: source,
//         destination: destination,
//         radius: 10,
//       );
//
//       // We only have LatLng markers from findRides,
//       // So let's fetch actual ride data from Firestore for those nearby sources.
//       // (Optional optimization: you can return full rides from findRides later)
//       final allRidesSnap = await rideRepository.getAllRides();
//       final List<RideModel> nearby = [];
//
//       for (final ride in allRidesSnap) {
//         for (final point in ridesRef) {
//           if ((ride.source.latitude - point.latitude).abs() < 0.01 &&
//               (ride.source.longitude - point.longitude).abs() < 0.01) {
//             nearby.add(ride);
//           }
//         }
//       }
//
//       rides.assignAll(nearby);
//     } catch (e) {
//       print("Error fetching available rides: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
