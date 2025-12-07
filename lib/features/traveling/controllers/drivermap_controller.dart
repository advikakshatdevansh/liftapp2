import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

enum TransportMode { driving, walking, bicycling, transit }

class DriverMapController extends GetxController {
  // Inputs passed from ChatController
  final String rideId;
  final LatLng passengerPickup;
  final LatLng finalDestination;

  DriverMapController({
    required this.rideId,
    required this.passengerPickup,
    required this.finalDestination,
  });

  late GoogleMapController mapController;
  final Completer<GoogleMapController> mapControllerCompleter = Completer();

  // Observable state
  var markers = <Marker>[].obs;
  var polylines = <Polyline>[].obs;
  var currentPosition = Rxn<Position>();
  var isLoading = true.obs;
  var distance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _checkPermissionsAndLocate();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapControllerCompleter.complete(controller);
  }

  // --- ZOOM FUNCTIONS (As per your code) ---
  void zoomIn() {
    mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    mapController.animateCamera(CameraUpdate.zoomOut());
  }

  // --- LOCATION & SETUP ---
  Future<void> _checkPermissionsAndLocate() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // Get initial position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    currentPosition.value = position;

    // Start live tracking
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position newPos) {
      currentPosition.value = newPos;
      _updateDriverMarker(newPos);
    });

    // Initialize Map Data
    await _setupMapData(position);
  }

  Future<void> _setupMapData(Position driverPos) async {
    final driverLatLng = LatLng(driverPos.latitude, driverPos.longitude);

    markers.clear();

    // 1. Add Passenger Marker (Source)
    markers.add(
      Marker(
        markerId: const MarkerId('passenger'),
        position: passengerPickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: "Passenger Pickup"),
      ),
    );

    // 2. Add Destination Marker
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: finalDestination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: "Final Destination"),
      ),
    );

    // 3. Add Driver Marker
    _updateDriverMarker(driverPos);

    // 4. Draw Route: Driver -> Passenger (To pick them up)
    // You can also draw Passenger -> Destination if you prefer.
    // Here we draw Driver -> Passenger so the driver knows where to go.
    await drawRoute(source: driverLatLng, destination: passengerPickup);

    // 5. Fit bounds
    _moveCameraToFit(driverLatLng, passengerPickup);

    isLoading.value = false;
  }

  void _updateDriverMarker(Position pos) {
    markers.removeWhere((m) => m.markerId.value == 'driver');
    markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(pos.latitude, pos.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        rotation: pos.heading,
        infoWindow: const InfoWindow(title: "You"),
      ),
    );
  }

  // --- ROUTING LOGIC (Copied & Adapted) ---

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
          polylineId: const PolylineId("route"),
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

    // OSRM API endpoint
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/$profile/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=polyline',
    );

    try {
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
      distance.value = (data['routes'][0]['distance'] as num) / 1000.0;

      return decodePolyline(encodedPolyline);
    } catch (e) {
      print("Error fetching route: $e");
      return [];
    }
  }

  String transportModeToOsmProfile(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return 'foot';
      case TransportMode.bicycling:
        return 'bike';
      case TransportMode.transit:
        return 'driving'; // Fallback
      case TransportMode.driving:
      default:
        return 'driving';
    }
  }

  // --- CUSTOM POLYLINE DECODING (Manual) ---
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
    // Use CameraUpdate.newLatLngBounds logic
    // Note: ensure mapController is initialized before calling this
    if (mapControllerCompleter.isCompleted) {
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }
}
