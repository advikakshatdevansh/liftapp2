// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../controllers/available_lifts_controller.dart';
//
// class AvailableLiftsScreen extends StatelessWidget {
//   final LatLng source;
//   final LatLng destination;
//
//   const AvailableLiftsScreen({
//     super.key,
//     required this.source,
//     required this.destination,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(AvailableLiftsController());
//
//     // Fetch rides when the screen loads
//     controller.fetchAvailableRides(source: source, destination: destination);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Available Lifts'),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (controller.rides.isEmpty) {
//           return const Center(child: Text('No available rides nearby.'));
//         }
//
//         return ListView.builder(
//           itemCount: controller.rides.length,
//           itemBuilder: (context, index) {
//             final ride = controller.rides[index];
//             return Card(
//               margin: const EdgeInsets.all(10),
//               child: ListTile(
//                 leading: const Icon(Icons.directions_car, color: Colors.blue),
//                 title: Text('${ride.sourceName} → ${ride.destinationName}'),
//                 subtitle: Text(
//                   'Distance: ${ride.distanceKm.toStringAsFixed(1)} km\n'
//                   'Seats Available: ${ride.seatsAvailable}',
//                 ),
//                 trailing: Text(
//                   ride.status,
//                   style: const TextStyle(color: Colors.green),
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }
