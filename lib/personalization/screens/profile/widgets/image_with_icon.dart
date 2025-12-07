import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../common/widgets/shimmers/shimmer.dart';
import '../../../controllers/user_controller.dart'; // Ensure this import path is correct
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/image_strings.dart';

class ImageWithIcon extends StatelessWidget {
  const ImageWithIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;

    return Stack(
      children: [
        // 1. Image Display (Reactive to user data and loading state)
        Obx(() {
          final networkImage = userController.user.value.profilePicture;
          // Use network image if available, otherwise use local placeholder
          final image = networkImage.isNotEmpty
              ? networkImage
              : TImages.tProfileImage;

          // Show shimmer effect while uploading
          return userController.imageUploading.value
              ? const TShimmerEffect(
            width: 120, // Increased size for ImageWithIcon
            height: 120,
            radius: 100,
          )
          // Show the image once available
              : TRoundedImage(
            width: 120, // Match the original SizedBox width
            height: 120, // Match the original SizedBox height
            isNetworkImage: networkImage.isNotEmpty,
            fit: BoxFit.fill,
            imageUrl: image,
            borderRadius: 60, // Use half of width/height for circular
          );
        }),

        // 2. Edit Icon (Pencil)
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            // Disable tap if image is currently uploading
            onTap: userController.imageUploading.value
                ? () {}
                : () => userController.uploadUserProfilePicture(),
            child: Container(
              width: 35, // Match the size in the original ImageWithIcon
              height: 35, // Match the size in the original ImageWithIcon
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), // Circular background
                color: TColors.primary,
              ),
              child: const Icon(
                LineAwesomeIcons.pencil_alt_solid,
                color: Colors.black,
                size: 20, // Match the size in the original ImageWithIcon
              ),
            ),
          ),
        ),
      ],
    );
  }
}