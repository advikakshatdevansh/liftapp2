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
      padding: const EdgeInsets.only(top: TSizes.xl - 15, bottom: TSizes.xl),
      child: Form(
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

            const SizedBox(height: 12),

            // Map Selection Button
            TextButton.icon(
              onPressed: controller.openMap,
              icon: const Icon(Icons.map),
              label: const Text('Select On Map'),
            ),

            const SizedBox(height: 8),

            // Suggestions List
            Obx(() {
              if (controller.suggestions.isEmpty) return const SizedBox();

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
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
                        color: Colors.grey,
                      ),
                      title: Text(
                        prediction["description"],
                        style: const TextStyle(fontSize: 14),
                      ),
                      onTap: () => controller.selectSuggestion(prediction),
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.bookRide,
                child: const Text('Book Ride'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
