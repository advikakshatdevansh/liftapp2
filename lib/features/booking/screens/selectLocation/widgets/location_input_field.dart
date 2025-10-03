import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../../../controllers/location_controller.dart';

class LocationTextField extends StatelessWidget {
  final LocationField field;
  final String hint;
  final IconData icon;
  final Function(String) onChanged;
  final bool autofocus;

  const LocationTextField({
    super.key,
    required this.field,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: field.controller,
      focusNode: field.focusNode,
      autofocus: autofocus,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (_) {
        if (!field.isValid.value) {
          return "Please select a valid location from the suggestions";
        }
        return null;
      },
    );
  }
}

class LocationInputField extends StatelessWidget {
  final String hint;
  final Function(Prediction) onSelected;
  final Widget? suffix;
  final TextEditingController controller;

  const LocationInputField({
    super.key,
    required this.hint,
    required this.onSelected,
    required this.controller,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return GooglePlaceAutoCompleteTextField(
      textEditingController: controller,
      googleAPIKey:
          "AIzaSyCt3L7NKLGXvdO94-laFxzUPMPWNRzH9Q4", // Replace with your actual API key
      inputDecoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        prefixIcon: Icon(
          hint.contains("From") ? Icons.my_location : Icons.location_on,
          color: Colors.grey.shade600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      debounceTime: 600, // Reduced for better UX
      countries: const ["in"], // Restrict to India

      isLatLngRequired: true,
      getPlaceDetailWithLatLng: (prediction) {
        // This gives you lat/lng if needed
        onSelected(prediction);
      },
      itemClick: (prediction) {
        onSelected(prediction);
      },
      seperatedBuilder: const Divider(height: 1),
      itemBuilder: (context, index, prediction) {
        return Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  prediction.description ?? "",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
