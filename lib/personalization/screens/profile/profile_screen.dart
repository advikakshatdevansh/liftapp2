import 'package:liftapp2/personalization/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../../common/widgets/buttons/primary_button.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../common/widgets/images/t_rounded_image.dart';
import '../../../common/widgets/shimmers/shimmer.dart';
import '../../../data/repository/notifications/authrepository.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../controllers/theme_controller.dart';
import 'update_profile_screen.dart';
import 'widgets/profile_menu.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});


  @override
  Widget build(BuildContext context) {
    // final dark = THelperFunctions.isDarkMode(context);
    final themeController = ThemeController.instance;
    final userController = UserController.instance;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(LineAwesomeIcons.angle_left_solid),
        ),
        title: Text(
          TTexts.tProfile,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// -- IMAGE with ICON
              // const ImageWithIcon(),
              Stack(
                children: [
                  Obx(() {
                    final networkImage =
                        userController.user.value.profilePicture;
                    final image = networkImage.isNotEmpty
                        ? networkImage
                        : TImages.tProfileImage;
                    return userController.imageUploading.value
                        ? const TShimmerEffect(
                            width: 80,
                            height: 80,
                            radius: 100,
                          )
                        : TRoundedImage(
                            width: 80,
                            height: 80,
                            isNetworkImage: networkImage.isNotEmpty,
                            fit: BoxFit.fill,
                            imageUrl: image,
                            borderRadius: 50,
                          );
                  }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: userController.imageUploading.value
                          ? () {}
                          : () => userController.uploadUserProfilePicture(),
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: TColors.primary,
                        ),
                        child: Icon(
                          LineAwesomeIcons.pencil_alt_solid,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                UserController.instance.user.value.fullName.isEmpty
                    ? TTexts.tProfileHeading
                    : UserController.instance.user.value.fullName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                UserController.instance.user.value.email.isEmpty
                    ? TTexts.tProfileSubHeading
                    : UserController.instance.user.value.email,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              /// -- BUTTON
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => UpdateProfileScreen()),
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    TTexts.tEditProfile,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),

              /// -- MENU
              ProfileMenuWidget(
                title: "Home",
                icon: Icons.home,
                onPress: () => Get.toNamed(TRoutes.home),
              ),
              ProfileMenuWidget(
                title: "Chats",
                icon: Icons.message,
                onPress: () => Get.toNamed(TRoutes.chatsScreen),
              ),

              // --- Divider for Section Separation ---
              const Divider(height: 30, thickness: 1),

              // --- Settings & Privacy Section ---
              ProfileMenuWidget(
                title: "Settings",
                icon: Icons.settings,
                onPress: () => Get.toNamed(TRoutes.settingsScreen), // New Route
              ),
              ProfileMenuWidget(
                title: "Privacy Policy",
                icon: Icons.lock,
                onPress: () => Get.toNamed(TRoutes.privacyPolicyScreen), // New Route
              ),
              ProfileMenuWidget(
                title: "Manage Subscription",
                icon: Icons.credit_card, // Or Icons.redeem
                onPress: () => Get.toNamed(TRoutes.home), // New Route
              ),

              // --- Divider for Section Separation ---
              const Divider(height: 30, thickness: 1),

              // --- Support & Information Section ---
              ProfileMenuWidget(
                title: "Help & Support",
                icon: Icons.help_outline,
                onPress: () => Get.toNamed(TRoutes.helpandsupportScreen), // New Route
              ),
              ProfileMenuWidget(
                title: "Rate Us",
                icon: Icons.star_rate_rounded,
                // You might use a package launcher for this
                onPress: () => Get.toNamed(TRoutes.rateUsScreen), // New Route
              ),
              const Divider(height: 30, thickness: 1),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutModal() {
    Get.defaultDialog(
      title: "LOGOUT",
      titleStyle: const TextStyle(fontSize: 20),
      content: const Padding(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: Text("Are you sure, you want to Logout?"),
      ),
      confirm: TPrimaryButton(
        isFullWidth: false,
        onPressed: () => AuthenticationRepository.instance.logout(),
        text: "Yes",
      ),
      cancel: SizedBox(
        width: 100,
        child: OutlinedButton(
          onPressed: () => Get.back(),
          child: const Text("No"),
        ),
      ),
    );
  }
}
