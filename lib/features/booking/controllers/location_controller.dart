import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:liftapp2/features/booking/screens/viewRoute/view_route_screen.dart';
import '../screens/selectOnMap/select_on_map_screen.dart';

enum LocationFieldType { source, destination }

class LocationsController extends GetxController {
  GlobalKey<FormState> locationsFormKey = GlobalKey<FormState>();

  late final LocationField sourceField;
  late final LocationField destinationField;

  var suggestions = [].obs;
  var activeField = Rxn<LocationFieldType>();
  LatLng? lastKnowPos;

  @override
  void onInit() {
    super.onInit();
    sourceField = LocationField(type: LocationFieldType.source);
    destinationField = LocationField(type: LocationFieldType.destination);

    sourceField.focusNode.addListener(_onFocusChange);
    destinationField.focusNode.addListener(_onFocusChange);
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    await _setCurrentLocationAsSource();
  }

  @override
  void onClose() {
    sourceField.dispose();
    destinationField.dispose();
    super.onClose();
  }

  void _onFocusChange() {
    if (sourceField.focusNode.hasFocus) {
      activeField.value = LocationFieldType.source;
    } else if (destinationField.focusNode.hasFocus) {
      activeField.value = LocationFieldType.destination;
    } else {
      activeField.value = null;
    }
  }

  LocationField get currentField {
    if (activeField.value == LocationFieldType.destination) {
      return destinationField;
    }
    return sourceField;
  }

  Future<void> _setCurrentLocationAsSource() async {
    final pos = await getCurrentPosition();
    if (pos != null) {
      sourceField.setLocation("Current Location", pos);
    } else {
      print("Failed to get current location on init");
    }
  }

  Future<LatLng?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Location Disabled", "Please enable GPS to continue");
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Permission Denied", "Location permission is required");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          "Permission Denied",
          "Enable location permission in settings",
        );
        return null;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition();

      lastKnowPos = LatLng(position.latitude, position.longitude);
      return lastKnowPos;
    } catch (e) {
      print("Location fetch failed: $e");
      Get.snackbar("Error", "Unable to get current location");
      return null;
    }
  }

  /// 🗺️ Autocomplete with OpenStreetMap (Nominatim)
  Future<void> onLocationTextChanged(String input) async {
    currentField.invalidate();

    if (input.trim().isEmpty) {
      suggestions.clear();
      return;
    }

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=$input'
      '&format=json'
      '&addressdetails=1'
      '&limit=5',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'LiftApp/1.0 (contact@yourapp.com)'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print(data);
        suggestions.assignAll(data);
      } else {
        print("Autocomplete failed: ${response.statusCode}");
        suggestions.clear();
      }
    } catch (e) {
      print("Autocomplete error: $e");
      suggestions.clear();
    }
  }

  /// When a suggestion is selected
  Future<void> selectSuggestion(Map<String, dynamic> prediction) async {
    final field = currentField;
    final description = prediction['display_name'] ?? 'Unknown place';
    final lat = double.tryParse(prediction['lat'].toString()) ?? 0.0;
    final lon = double.tryParse(prediction['lon'].toString()) ?? 0.0;

    field.controller.text = description;
    suggestions.clear();

    field.setLocation(description, LatLng(lat, lon));
  }

  /// Reverse geocoding for map-tap
  Future<String?> getAddressFromLatLng(LatLng position) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=${position.latitude}'
      '&lon=${position.longitude}'
      '&format=json',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'LiftApp/1.0 (contact@yourapp.com)'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['display_name'];
      }
    } catch (e) {
      print("Reverse geocoding failed: $e");
    }
    return null;
  }

  Future<void> openMap() async {
    LatLng currentPosition = lastKnowPos ?? LatLng(0, 0);

    if (lastKnowPos == null) {
      final pos = await getCurrentPosition();
      if (pos != null) currentPosition = pos;
    }

    final fieldType = activeField.value;

    final result = await Get.to<LatLng>(
      () => SelectOnMap(currentPosition: currentPosition),
    );

    if (result != null) {
      final field = fieldType == LocationFieldType.destination
          ? destinationField
          : sourceField;

      final address = await getAddressFromLatLng(result);
      field.setLocation(address ?? "Selected Location", result);
    }
  }

  Future<void> bookRide() async {
    if (locationsFormKey.currentState!.validate()) {
      if (sourceField.latLng.value != null &&
          destinationField.latLng.value != null) {
        Get.to(
          () => ViewRoute(
            source: sourceField.latLng.value!,
            destination: destinationField.latLng.value!,
            sourcename: sourceField.controller.text,
            destinationname: destinationField.controller.text,
          ),
        );
      }
    } else {
      Get.snackbar("Invalid Input", "Please select valid locations");
    }
  }

  String? validateField(LocationFieldType type) {
    final field = type == LocationFieldType.source
        ? sourceField
        : destinationField;
    if (!field.isValid.value) {
      return "Please select a valid location from the suggestions";
    }
    return null;
  }
}

class LocationField {
  final TextEditingController controller;
  final FocusNode focusNode;
  final RxBool isValid;
  final Rxn<LatLng> latLng;
  final LocationFieldType type;

  LocationField({required this.type, String? initialText})
    : controller = TextEditingController(text: initialText),
      focusNode = FocusNode(),
      isValid = false.obs,
      latLng = Rxn<LatLng>();

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }

  void setLocation(
    String address,
    LatLng coordinates, {
    bool markValid = true,
  }) {
    controller.text = address;
    latLng.value = coordinates;
    if (markValid) isValid.value = true;
  }

  void invalidate() {
    isValid.value = false;
    latLng.value = null;
  }

  void clear() {
    controller.clear();
    latLng.value = null;
    isValid.value = false;
  }
}
