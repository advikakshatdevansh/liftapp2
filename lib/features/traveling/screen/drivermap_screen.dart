import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controllers/drivermap_controller.dart';

class DriverMapScreen extends StatelessWidget {
  final String rideId;
  final GeoPoint passengerPickup;
  final GeoPoint finalDestination;

  const DriverMapScreen({
    super.key,
    required this.rideId,
    required this.passengerPickup,
    required this.finalDestination,
  });

  @override
  Widget build(BuildContext context) {
    // Convert Firestore GeoPoints to Google Maps LatLng
    final pickupLatLng = LatLng(
      passengerPickup.latitude,
      passengerPickup.longitude,
    );
    final destLatLng = LatLng(
      finalDestination.latitude,
      finalDestination.longitude,
    );

    // Initialize Controller
    final controller = Get.put(
      DriverMapController(
        rideId: rideId,
        passengerPickup: pickupLatLng,
        finalDestination: destLatLng,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map
          Obx(() {
            if (controller.isLoading.value &&
                controller.currentPosition.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: pickupLatLng, // Focus on passenger initially
                zoom: 14,
              ),
              mapType: MapType.normal,
              myLocationEnabled: true, // Shows blue dot
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: controller.markers.toSet(),
              polylines: controller.polylines.toSet(),
              onMapCreated: controller.onMapCreated,
            );
          }),

          // 2. Info Panel (Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Heading to Passenger",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "The route is highlighted. Follow the line to the pickup point.",
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[900],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        // Logic to switch route to "Pickup -> Destination"
                        // or complete ride
                        Get.snackbar("Status", "Navigate carefully!");
                      },
                      icon: const Icon(Icons.navigation, color: Colors.white),
                      label: const Text(
                        "Start Navigation",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Back Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
