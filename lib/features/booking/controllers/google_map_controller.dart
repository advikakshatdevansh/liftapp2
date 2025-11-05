import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:liftapp2/data/repository/ride_repository/ride_repository.dart';

enum TransportMode { driving, walking, bicycling, transit }

class CustomMapController extends GetxController {
  late GoogleMapController mapController;
  var markers = <Marker>[].obs;
  var polylines = <Polyline>[].obs;
  var distance = 0.0.obs;

  final String apiKey =
      "AIzaSyCt3L7NKLGXvdO94-laFxzUPMPWNRzH9Q4";

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> addMarkers({
    required LatLng source,
    required LatLng destination,
  }) async {
    markers.clear();

    // Add user’s own source + destination markers
    markers.add(Marker(markerId: const MarkerId("source"), position: source));
    markers.add(
      Marker(markerId: const MarkerId("destination"), position: destination),
    );

    // Draw user’s route
    await drawRoute(source: source, destination: destination);

    // Adjust camera
    _moveCameraToFit(source, destination);

    // 🔍 Find nearby rides
    final List<LatLng> rides = await RideRepository.instance.findRides(
      source,
      destination,
      10, // radius in km
    );
    print(rides);

    if (rides.isNotEmpty) {
      // 🧭 Add ride source markers on the map
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
    }

    markers.refresh();
  }

  Future<void> drawRoute({
    required LatLng source,
    required LatLng destination,
  }) async {
    final points = await getRoutePoints(
      origin: source,
      destination: destination,
      apiKey: apiKey,
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
    required String apiKey,
    TransportMode mode = TransportMode.driving,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&mode=${transportModeToString(mode)}'
      '&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    print(
      "Directions API response: ${data['status']} - ${data['error_message']}",
    );

    if (data['status'] != 'OK') return [];

    final encodedPolyline = data['routes'][0]['overview_polyline']['points'];
    distance.value =
        (data['routes'][0]['legs'][0]['distance']['value'] / 1000.0);
    return decodePolyline(encodedPolyline);
  }

  String transportModeToString(TransportMode mode) {
    switch (mode) {
      case TransportMode.driving:
        return 'driving';
      case TransportMode.walking:
        return 'walking';
      case TransportMode.bicycling:
        return 'bicycling';
      case TransportMode.transit:
        return 'transit';
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
