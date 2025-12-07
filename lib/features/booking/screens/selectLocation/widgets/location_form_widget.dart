import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/location_controller.dart';
import 'location_input_field.dart';

class LocationFormWidget extends StatelessWidget {
  const LocationFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LocationsController());

    return Container(
      padding: const EdgeInsets.only(
        top: TSizes.xl - 16,
        bottom: TSizes.xl,
        left: TSizes.xs,   // Assuming TSizes.defaultSpace is your standard horizontal padding
        right: TSizes.xs,  // Add padding to the right
      ),      child: Form(
        key: controller.locationsFormKey,
        child: Column(
          children: [
            // Source Field
            LocationTextField(
              field: controller.sourceField,
              hint: "Current Location",
              icon: Icons.my_location,
              onChanged: controller.onLocationTextChanged,
            ),

            const SizedBox(height: 16),

            // Destination Field
            LocationTextField(
              field: controller.destinationField,
              hint: "Enter destination",
              icon: Icons.location_on,
              onChanged: controller.onLocationTextChanged,
              autofocus: true,
            ),

            const SizedBox(height: 6),

            // Map Selection Button


            // const SizedBox(height: 8),

            // Suggestions List
            Obx(() {
              if (controller.suggestions.isEmpty) return const SizedBox();

              return Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.suggestions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final prediction = controller.suggestions[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      title: Text(
                        prediction["display_name"] ?? 'Unknown place',
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => controller.selectSuggestion(prediction),
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 8),

            // 1. 'Select On Map' Button (Now full width)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: controller.openMap,
                icon: const Icon(Icons.location_on),
                label: const Text(
                  'Select On Map',
                  style: TextStyle( // Added the specific TextStyle here
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: FilledButton.styleFrom(
                  // Set background to white
                  backgroundColor: Colors.white,
                  // Set foreground (icon) to black
                  foregroundColor: Colors.black,
                  // Matches the vertical padding: 13
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    // Matches the large border radius: 40
                    borderRadius: BorderRadius.circular(40),
                  ),
                  // Matches the light grey border
                  side: const BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: controller.bookRide,
                style: FilledButton.styleFrom(
                  // Set background to white
                  backgroundColor: Colors.white,
                  // Set foreground (text) to black
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  // Optional: Add a light border to distinguish it from the white background
                  side: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                child: const Text(
                  'Book Ride',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
