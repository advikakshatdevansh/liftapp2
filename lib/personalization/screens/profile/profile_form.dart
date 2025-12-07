import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:get/get.dart'; // Added Get import for controller instance

import '../../../../../personalization/controllers/user_controller.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../utils/helpers/helper_functions.dart';

class ProfileFormScreen extends StatelessWidget {
  const ProfileFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller instance is correctly accessed
    final controller = UserController.instance;

    // Define the primary red color for high-contrast alerts
    const Color dangerColor = Colors.red;

    return Form(
      key: controller.updateUserProfileFormKey,
      child: Column(
        children: [
          // Full Name Field
          TextFormField(
            controller: controller.fullName,
            decoration: const InputDecoration(label: Text(TTexts.tFullName), prefixIcon: Icon(LineAwesomeIcons.user)),
          ),
          const SizedBox(height: TSizes.defaultSpace), // Use standard spacing

          // Email Field
          TextFormField(
            // Use Obx to reactively check if email is empty (allowing editing only if empty)
            enabled: controller.email.text.isEmpty,
            controller: controller.email,
            decoration: const InputDecoration(label: Text(TTexts.tEmail), prefixIcon: Icon(LineAwesomeIcons.envelope)),
          ),
          const SizedBox(height: TSizes.defaultSpace), // Use standard spacing

          // Phone Number Field
          TextFormField(
            // Use Obx to reactively check if phoneNo is empty (allowing editing only if empty)
            enabled: controller.phoneNo.text.isEmpty,
            controller: controller.phoneNo,
            decoration: const InputDecoration(label: Text(TTexts.tPhoneNo), prefixIcon: Icon(LineAwesomeIcons.phone_solid)),
          ),
          const SizedBox(height: TSizes.defaultSpace),
          /// -- Form Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.updateUserProfile(),
              child: const Text(TTexts.tEditProfile),
            ),
          ),
          const SizedBox(height: TSizes.defaultSpace * 2), // Larger spacing before details/delete section

          /// -- Created Date and Delete Button
          // 1. Created Date Display (Kept as a Row for alignment)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: TTexts.tJoined,
                  style: Theme.of(context).textTheme.bodySmall, // Use theme for smaller text
                  children: [
                    TextSpan(
                      // Use Obx to ensure the date is loaded correctly
                      text: THelperFunctions.getFormattedDate(controller.user.value.createdAt ?? DateTime.now()),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Empty space to maintain balance if Delete is moved below
              const SizedBox.shrink(),
            ],
          ),
              const SizedBox(height: 10),
          /// -- DELETE ACCOUNT Button (Revised UI)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => controller.deleteAccountWarningPopup(),
              icon: const Icon(LineAwesomeIcons.trash_alt_solid, size: 20),
              label: const Text(TTexts.tDelete),
              style: OutlinedButton.styleFrom(
                // High visibility red border
                side: const BorderSide(color: dangerColor, width: 1.5),
                foregroundColor: dangerColor,
                backgroundColor: Colors.transparent, // Ensure it's white/transparent
                padding: const EdgeInsets.symmetric(vertical: TSizes.buttonHeight - 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}