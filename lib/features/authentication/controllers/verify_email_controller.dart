
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../common/widgets/success_screen/success_screen.dart';
import '../../../data/repository/notifications/authrepository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/popups/loaders.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  @override
  void onInit() {
    /// Send Email Whenever Verify Screen appears & Set Timer for auto redirect.
    sendEmailVerification();
    // setTimerForAutoRedirect();

    super.onInit();
  }

  /// Send Email Verification link
  Future<void> sendEmailVerification() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification();
      TLoaders.successSnackBar(
        title: 'Email Sent',
        message: 'Please Check your inbox and verify your email.',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Verification!', message: e.toString());
    }
  }

  /// Timer to automatically redirect on Email Verification
  // setTimerForAutoRedirect() {
  //   Timer.periodic(const Duration(seconds: 1), (timer) async {
  //     await FirebaseAuth.instance.currentUser?.reload();
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user?.emailVerified ?? false) {
  //       timer.cancel();
  //       Get.off(
  //         () => SuccessScreen(
  //           image: TImages.successfullyRegisterAnimation,
  //           title: TTexts.yourAccountCreatedTitle,
  //           subTitle: TTexts.yourAccountCreatedSubTitle,
  //           onPressed: () => AuthenticationRepository.instance.screenRedirect(
  //             FirebaseAuth.instance.currentUser,
  //           ),
  //         ),
  //       );
  //     }
  //   });
  // }

  /// Manually Check if Email Verified
  Future<void> checkEmailVerificationStatus() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.emailVerified) {
      Get.off(
        () => SuccessScreen(
          image: TImages.successfullyRegisterAnimation,
          title: TTexts.yourAccountCreatedTitle,
          subTitle: TTexts.yourAccountCreatedSubTitle,
          onPressed: () => AuthenticationRepository.instance.screenRedirect(
            FirebaseAuth.instance.currentUser,
          ),
        ),
      );
    } else {
      TLoaders.errorSnackBar(
        title: 'Oh Verification!',
        message: 'Not Verified',
      );
    }
  }
}
