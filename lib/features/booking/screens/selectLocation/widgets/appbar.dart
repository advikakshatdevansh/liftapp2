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
    final networkImage = UserController.instance.user.value.profilePicture;
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
        Container(
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: dark ? TColors.secondary : TColors.cardBackgroundColor,
          ),
          child: IconButton(
            onPressed: () => Get.toNamed(TRoutes.profileScreen),
            icon: TRoundedImage(
              width: 60,
              height: 60,
              isNetworkImage: networkImage.isNotEmpty,
              fit: BoxFit.fill,
              imageUrl: image,
              borderRadius: 50,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(55);
}
