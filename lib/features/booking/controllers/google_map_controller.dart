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

    // 🔍 Find nearby rides
    final List<LatLng> rides = await RideRepository.instance.getAllRideSources(
      source: source,
      destination: destination,
    );
    print(rides);
    print(
      await RideRepository.instance.findRides(
        source: source,
        destination: destination,
      ),
    );

    if (rides.isNotEmpty) {
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
