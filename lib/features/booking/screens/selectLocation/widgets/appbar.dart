import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/image_strings.dart';
import '../../../../../../utils/constants/text_strings.dart';
import '../../../../../../utils/helpers/helper_functions.dart';
import '../../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../../personalization/controllers/user_controller.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;
    final networkImage = userController.user.value.profilePicture;
    final image = networkImage.isNotEmpty
        ? networkImage
        : TImages.tProfileImage;
    final dark = THelperFunctions.isDarkMode(context);

    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      title: Text(
        TTexts.tAppName,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () => Get.toNamed(TRoutes.profileScreen),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: dark ? TColors.secondary : TColors.cardBackgroundColor,
              ),
              child: TRoundedImage(
                width: 60,
                height: 60,
                isNetworkImage: networkImage.isNotEmpty,
                fit: BoxFit.cover,
                imageUrl: image,
                borderRadius: 50,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(55);
}
