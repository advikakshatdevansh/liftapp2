import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:liftapp2/features/booking/screens/viewRoute/view_route_screen.dart';
import '../screens/selectOnMap/select_on_map_screen.dart';

enum LocationFieldType { source, destination }

class LocationsController extends GetxController {
  final String apiKey = "AIzaSyCt3L7NKLGXvdO94-laFxzUPMPWNRzH9Q4";
  GlobalKey<FormState> locationsFormKey = GlobalKey<FormState>();

  // Improved field management
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

    // Listen to focus changes
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
    if (activeField.value == LocationFieldType.source) {
      return sourceField;
    }
    if (activeField.value == LocationFieldType.destination) {
      return destinationField;
    }
    return sourceField; // default
  }

  Future<void> _setCurrentLocationAsSource() async {
    final pos = await getCurrentPosition();
    if (pos != null) {
      sourceField.setLocation("", pos);
    } else {
      print("Failed to get location onready");
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

      // Wrap this in try-catch
      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
        if (position != null) {
          lastKnowPos = LatLng(position.latitude, position.longitude);
          print("Using cached GPS position: $lastKnowPos");
          return lastKnowPos;
        }
      } catch (e) {
        print("Could not get last known position: $e");
      }

      print("Getting fresh location...");
      position = await Geolocator.getCurrentPosition();

      lastKnowPos = LatLng(position.latitude, position.longitude);
      print("Fresh position obtained: $lastKnowPos");
      return lastKnowPos;
    } catch (e) {
      print("Location fetch failed: $e");
      Get.snackbar("Error", "Unable to get current location");
      return null;
    }
  }

  void onLocationTextChanged(String input) async {
    currentField.invalidate();

    if (input.trim().isEmpty) {
      suggestions.clear();
      return;
    }

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json"
      "?input=$input&key=$apiKey&components=country:in",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      suggestions.assignAll(data["predictions"]);
    } else {
      suggestions.clear();
    }
  }

  Future<void> selectSuggestion(Map<String, dynamic> prediction) async {
    final String placeId = prediction['place_id'];
    final String description = prediction['description'];

    // Get the active field
    final field = currentField;

    // Update UI immediately
    field.controller.text = description;
    suggestions.clear();

    // Fetch coordinates
    final Map<String, dynamic> placeDetails = await getPlaceDetails(placeId);

    if (placeDetails.isNotEmpty) {
      final location = placeDetails['geometry']['location'];
      final lat = location['lat'];
      final lng = location['lng'];

      field.setLocation(description, LatLng(lat, lng));
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&key=$apiKey'
        '&fields=geometry';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['status'] == 'OK') {
          return decodedResponse['result'];
        }
      }
    } catch (e) {
      print('Error fetching place details: $e');
    }

    return {};
  }

  Future<void> bookRide() async {
    if (locationsFormKey.currentState!.validate()) {
      print("Form submitted!");

      print("Destination: ${destinationField.latLng.value}");
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
      print("Please select valid locations from suggestions.");
    }
  }

  Future<void> openMap() async {
    LatLng currentPosition = LatLng(0, 0);
    if (lastKnowPos != null) {
      currentPosition = lastKnowPos!;
      print("using pos known at onready");
    } else {
      currentPosition = (await getCurrentPosition())!;
      if (currentPosition == null) {
        Get.snackbar("Could not open map", "");
        return;
      }
      print("fetching new pos");
    }

    print("start opening map");

    final fieldType = activeField.value;

    final result = await Get.to<LatLng>(
      () => SelectOnMap(currentPosition: currentPosition),
    );

    if (result != null) {
      final field = fieldType == LocationFieldType.source
          ? sourceField
          : destinationField;
      final address = await getAddressFromLatLng(result);
      field.setLocation(address ?? result.toString(), result);
    } else {
      print("User cancelled map selection");
    }
  }

  Future<String?> getAddressFromLatLng(LatLng position) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=${position.latitude},${position.longitude}'
      '&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
    } catch (e) {
      print("Reverse geocoding failed: $e");
    }

    return null;
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
