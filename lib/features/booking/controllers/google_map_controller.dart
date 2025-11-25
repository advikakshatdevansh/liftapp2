import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:liftapp2/data/repository/ride_repository/ride_repository.dart';

import '../../../data/repository/lift_repository/lift_repository.dart';

enum TransportMode { driving, walking, bicycling, transit }

class CustomMapController extends GetxController {
  late GoogleMapController mapController;
  var markers = <Marker>[].obs;
  var polylines = <Polyline>[].obs;
  var distance = 0.0.obs;

  var isListReady = false.obs; // enables next button
  var isRide = false.obs;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> addMarkers({
    required LatLng source,
    required LatLng destination,
  }) async {
    markers.clear();

    // markers.add(Marker(markerId: const MarkerId("source"), position: source));
    markers.add(
      Marker(markerId: const MarkerId("destination"), position: destination),
    );

    // Draw user’s route
    await drawRoute(source: source, destination: destination);

    // Adjust camera
    _moveCameraToFit(source, destination);

    // // 🔍 Find nearby rides
    // final List<LatLng> rides = await RideRepository.instance.getAllRideSources(
    //   source: source,
    //   destination: destination,
    //   radius: 1,
    // );
    //
    // if (rides.isNotEmpty) {
    //   for (int i = 0; i < rides.length; i++) {
    //     final ridePos = rides[i];
    //     markers.add(
    //       Marker(
    //         markerId: MarkerId('ride_$i'),
    //         position: ridePos,
    //         icon: BitmapDescriptor.defaultMarkerWithHue(
    //           BitmapDescriptor.hueGreen,
    //         ),
    //         infoWindow: InfoWindow(
    //           title: 'Available Ride ${i + 1}',
    //           snippet:
    //               'Lat: ${ridePos.latitude.toStringAsFixed(4)}, Lng: ${ridePos.longitude.toStringAsFixed(4)}',
    //         ),
    //       ),
    //     );
    //   }
    // }
    //
    // markers.refresh();
  }

  Future<void> displayNearbyRides({
    required LatLng source,
    required LatLng destination,
    double radius = 1,
  }) async {
    // Clear only ride markers (keep existing route markers if any)
    markers.removeWhere((m) => m.markerId.value.startsWith("lift_"));
    markers.removeWhere((m) => m.markerId.value.startsWith("ride_"));

    // Fetch ride source positions
    final List<LatLng> rides = await RideRepository.instance.getAllRideSources(
      source: source,
      destination: destination,
      radius: radius,
    );

    if (rides.isEmpty) {
      Get.snackbar(
        "No Rides Found",
        "No available rides near this location",
        snackPosition: SnackPosition.BOTTOM,
      );
      markers.refresh();
      return;
    }

    // Add ride markers
    for (int i = 0; i < rides.length; i++) {
      final ridePos = rides[i];
      markers.add(
        Marker(
          markerId: MarkerId('ride_$i'),
          position: ridePos,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: 'Available Ride ${i + 1}',
            snippet:
                'Lat: ${ridePos.latitude.toStringAsFixed(4)}, Lng: ${ridePos.longitude.toStringAsFixed(4)}',
          ),
        ),
      );
    }

    markers.refresh();
    isListReady.value = true; // show next button
    isRide.value = false;
  }

  Future<void> displayNearbyLifts({
    required LatLng source,
    required LatLng destination,
    double radius = 3,
  }) async {
    try {
      // Remove previous lift markers
      markers.removeWhere((m) => m.markerId.value.startsWith("lift_"));
      markers.removeWhere((m) => m.markerId.value.startsWith("ride_"));
      // Fetch lifts
      final lifts = await LiftRepository.instance.getAllLiftSources(
        source: source,
        destination: destination,
        radius: radius,
      );

      if (lifts.isEmpty) {
        Get.snackbar(
          "No Lifts Found",
          "No nearby lifts available.",
          snackPosition: SnackPosition.BOTTOM,
        );
        markers.refresh();
        return;
      }

      // Add markers
      for (int i = 0; i < lifts.length; i++) {
        final liftPos = lifts[i];

        markers.add(
          Marker(
            markerId: MarkerId("lift_$i"),
            position: LatLng(liftPos.latitude, liftPos.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(
              title: "Lift ${i + 1}",
              snippet:
                  'Lat: ${liftPos.latitude.toStringAsFixed(4)}, Lng: ${liftPos.longitude.toStringAsFixed(4)}',
            ),
          ),
        );
      }
      markers.refresh();
      isListReady.value = true; // show next button
      isRide.value = true;
    } catch (e) {
      Get.snackbar("Error", "Failed to load lifts: $e");
    }
  }

  Future<void> drawRoute({
    required LatLng source,
    required LatLng destination,
  }) async {
    final points = await getRoutePoints(
      origin: source,
      destination: destination,
    );

    if (points.isNotEmpty) {
      polylines.clear();
      polylines.add(
        Polyline(
          polylineId: PolylineId("route"),
          points: points,
          color: Colors.blue,
          width: 5,
        ),
      );
    }
  }

  Future<List<LatLng>> getRoutePoints({
    required LatLng origin,
    required LatLng destination,
    TransportMode mode = TransportMode.driving,
  }) async {
    final profile = transportModeToOsmProfile(mode);

    // OSRM API endpoint (free, no API key)
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/$profile/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=polyline',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      print("OSRM request failed: ${response.statusCode}");
      return [];
    }

    final data = jsonDecode(response.body);
    if (data['routes'] == null || data['routes'].isEmpty) {
      print("No route found in OSRM response");
      return [];
    }

    final encodedPolyline = data['routes'][0]['geometry'];
    distance.value = data['routes'][0]['distance'] / 1000.0;

    return decodePolyline(encodedPolyline);
  }

  String transportModeToOsmProfile(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return 'foot';
      case TransportMode.bicycling:
        return 'bike';
      case TransportMode.transit:
        // OSRM doesn't directly support transit — fallback to driving
        return 'car';
      case TransportMode.driving:
      default:
        return 'car';
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return poly;
  }

  void _moveCameraToFit(LatLng source, LatLng destination) {
    final southwest = LatLng(
      source.latitude < destination.latitude
          ? source.latitude
          : destination.latitude,
      source.longitude < destination.longitude
          ? source.longitude
          : destination.longitude,
    );
    final northeast = LatLng(
      source.latitude > destination.latitude
          ? source.latitude
          : destination.latitude,
      source.longitude > destination.longitude
          ? source.longitude
          : destination.longitude,
    );

    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }
}
