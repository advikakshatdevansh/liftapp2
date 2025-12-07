import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../personalization/controllers/user_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../images/t_rounded_image.dart';

class TDrawer extends StatelessWidget {
  const TDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;
    final networkImage = userController.user.value.profilePicture;
    final image = networkImage.isNotEmpty
        ? networkImage
        : TImages.tProfileImage;
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => Get.toNamed(TRoutes.profileScreen),
            child: Container(
              color: TColors.textDarkSecondary,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile image
                  TRoundedImage(
                    width: 80,
                    height: 80,
                    isNetworkImage: networkImage.isNotEmpty,
                    fit: BoxFit.fill,
                    imageUrl: image,
                    borderRadius: 50,
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    userController.user.value.fullName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TColors.dark,
                    ),
                  ),
                  // Email
                  Text(
                    userController.user.value.email,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.apply(color: TColors.dark),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          ..._drawerItems(),

          const Spacer(),
        ],
      ),
    );
  }

  List<Widget> _drawerItems() {
    return [
      _buildDrawerItem(
        icon: Iconsax.user,
        title: "Profile",
        onTap: () => Get.toNamed(TRoutes.profileScreen),
      ),
      _buildDrawerItem(
        icon: Iconsax.like_dislike,
        title: "ActiveLifts",
        onTap: () => Get.toNamed(TRoutes.activeLifts),
      ),
      _buildDrawerItem(
        icon: Iconsax.message,
        title: "Chats",
        onTap: () => Get.toNamed(TRoutes.allchats),
      ),
      _buildDrawerItem(
        icon: Iconsax.home,
        title: "Home",
        onTap: () => Get.toNamed(TRoutes.home),
      ),
    ];
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap,
    );
  }
}
