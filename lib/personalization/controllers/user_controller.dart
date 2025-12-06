import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:liftapp2/utils/popups/exports.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../common/widgets/loaders/circular_loader.dart';
import '../../data/repository/notifications/authrepository.dart';
import '../../data/repository/user_repository/user_repository.dart';
import '../../data/services/notifications/notification_service.dart';
// import '../../features/authentication/screens/welcome/welcome_screen.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants/text_strings.dart';
import '../../utils/popups/full_screen_loader.dart';
import '../../utils/popups/loaders.dart';
import '../models/user_model.dart';
import '../../utils/constants/enums.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/network_manager.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
// import '../screens/profile/re_authenticate_user_login_form.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  /// Repositories
  Rx<UserModel> user = UserModel.empty().obs;
  final profileLoading = false.obs;
  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  // Profile Screen Controllers
  final email = TextEditingController();
  final phoneNo = TextEditingController();
  final fullName = TextEditingController();
  final imageUploading = false.obs;
  final profileImageUrl = ''.obs;
  GlobalKey<FormState> updateUserProfileFormKey = GlobalKey<FormState>();

  /// init user data when Home Screen appears
  @override
  void onInit() {
    fetchUserRecord();
    super.onInit();
  }

  /// Fetch user record
  Future<void> fetchUserRecord({bool fetchLatestRecord = false}) async {
    try {
      if (fetchLatestRecord) {
        profileLoading.value = true;
        final user = await userRepository.fetchUserDetails();
        this.user(user);
      } else {
        // Check if user is logged in and has a valid ID
        if (user.value.id != AuthenticationRepository.instance.getUserID) {
          user.value = UserModel.empty();
        }
        // Fetch user data from the repository
        if (user.value.id.isEmpty) {
          profileLoading.value = true;
          final user = await userRepository.fetchUserDetails();
          this.user(user);
        }
      }
    } catch (e) {
      TLoaders.warningSnackBar(
        title: 'Warning',
        message: 'Unable to fetch your information. Try again.',
      );
    } finally {
      profileLoading.value = false;
    }
  }

  /// Save user Record from any Registration provider
  Future<void> saveUserRecord({
    UserModel? user,
    UserCredential? userCredentials,
  }) async {
    try {
      // First UPDATE Rx User and then check if user data is already stored. If not store new data
      await fetchUserRecord();

      // If no record already stored.
      if (this.user.value.id.isEmpty) {
        if (userCredentials != null) {
          final fcmToken = await TNotificationService.getToken();
          // Map data
          final newUser = UserModel(
            id: userCredentials.user!.uid,
            fullName: userCredentials.user!.displayName ?? '',
            email: userCredentials.user!.email ?? '',
            profilePicture: userCredentials.user!.photoURL ?? '',
            deviceToken: fcmToken,
            isEmailVerified: true,
            isProfileActive: true,
            updatedAt: DateTime.now(),
            createdAt: DateTime.now(),
            verificationStatus: VerificationStatus.approved,
            phoneNumber: '',
          );

          // Save user data
          await userRepository.saveUserRecord(newUser);

          // Assign new user to the RxUser so that we can use it through out the app.
          this.user(newUser);
        } else if (user != null) {
          // Save Model when user registers using Email and Password
          await userRepository.saveUserRecord(user);

          // Assign new user to the RxUser so that we can use it through out the app.
          this.user(user);
        }
      }
    } catch (e) {
      TLoaders.warningSnackBar(
        title: 'Data not saved',
        message:
            'Something went wrong while saving your information. You can re-save your data in your Profile.',
      );
    }
  }

  Future<void> updateUserProfile() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog(
        'We are updating your information...',
        TImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!updateUserProfileFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Update user's first & last name in the Firebase Firestore
      Map<String, dynamic> json = {
        'fullName': fullName.text.trim(),
        'email': email.text.trim(),
      };
      await userRepository.updateSingleField(json);

      // Update the Rx User value
      user.value.fullName = fullName.text.trim();
      user.value.email = email.text.trim();
      user.value.phoneNumber = phoneNo.text.trim();

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Success Message
      TLoaders.successSnackBar(
        title: 'Congratulations',
        message: 'Your Name has been updated.',
      );

      // Move to previous screen.
      Get.offNamed(TRoutes.home);
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  Future<void> uploadUserProfilePicture() async {
    try {
      // Pick Image
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 512,
        maxWidth: 512,
      );

      if (picked == null) return;

      // Crop Image in Circle
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(
          ratioX: 1,
          ratioY: 1,
        ), // Square for circle
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle, // Circular crop here
          ),
          IOSUiSettings(
            title: 'Crop Profile Image',
            aspectRatioLockEnabled: true,
            rectX: 1, // ensure square
            rectY: 1,
            resetButtonHidden: true,
          ),
        ],
      );

      if (croppedFile == null) return;

      imageUploading.value = true;

      // Upload to Cloudinary
      final cloudinary = CloudinaryPublic('liftshare', 'pfp-app', cache: true);

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(croppedFile.path, folder: "Users/Profile"),
      );

      final uploadedUrl = response.secureUrl;

      // Save URL in Firestore
      await userRepository.updateSingleField({'profilePicture': uploadedUrl});

      // Update local user model
      user.value.profilePicture = uploadedUrl;
      user.refresh();
      profileImageUrl.value = uploadedUrl;

      imageUploading.value = false;

      TLoaders.successSnackBar(
        title: 'Congratulations',
        message: 'Your profile image has been updated!',
      );
    } catch (e) {
      imageUploading.value = false;
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: '$e');
    }
  }

  Future<void> updateUserRecordWithToken(String newToken) async {
    try {
      // Ensure we have fetched the user record before updating
      await fetchUserRecord();
      // Create a map to store the fields we want to update (e.g., token)
      Map<String, dynamic> updatedFields = {'deviceToken': newToken};

      // Call the repository to update the specific fields
      await userRepository.updateSingleField(updatedFields);

      // Update the local RxUser object with the new token
      user.value.deviceToken = newToken;
      user.refresh();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update user record: $e',
      );
    }
  }

  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Delete Account',
      middleText:
          'Are you sure you want to delete your account permanently? This action is not reversible and all of your data will be removed permanently.',
      confirm: ElevatedButton(
        onPressed: () async => deleteUserAccount(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text('Delete'),
        ),
      ),
      cancel: OutlinedButton(
        child: const Text('Cancel'),
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
      ),
    );
  }

  void deleteUserAccount() async {
    try {
      TFullScreenLoader.openLoadingDialog('Processing', TImages.docerAnimation);

      /// First re-authenticate user
      final auth = AuthenticationRepository.instance;
      final provider = auth.firebaseUser!.providerData
          .map((e) => e.providerId)
          .first;
      if (provider.isNotEmpty) {
        // Re Verify Auth Email
        if (provider == 'google.com') {
          await auth.signInWithGoogle();
          await auth.deleteAccount();
          TFullScreenLoader.stopLoading();
          Get.offAllNamed(TRoutes.onboarding);
        } else if (provider == 'facebook.com') {
          TFullScreenLoader.stopLoading();
          Get.offAllNamed(TRoutes.onboarding);
        } else if (provider == 'password') {
          TFullScreenLoader.stopLoading();
          // Get.to(() => const ReAuthLoginForm());
          await AuthenticationRepository.instance.deleteAccount();
        } else if (provider == 'phone') {
          TFullScreenLoader.stopLoading();
          await AuthenticationRepository.instance.loginWithPhoneNo(
            user.value.phoneNumber,
          );
          // bool otpVerified = await Get.toNamed(
          //   AppRoutes.reAuthenticateOtpVerification,
          //   parameters: {'phoneNumberWithCountryCode': user.value.phoneNumber},
          // );
          if (true) {
            TLoaders.successSnackBar(
              title: TTexts.phoneVerifiedTitle,
              message: TTexts.phoneVerifiedMessage,
            );
            await auth.deleteAccount();
            Get.offAllNamed(TRoutes.onboarding);
          }
        }
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      TFullScreenLoader.openLoadingDialog('Processing', TImages.docerAnimation);

      //Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      if (!reAuthFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance
          .reAuthenticateWithEmailAndPassword(
            verifyEmail.text.trim(),
            verifyPassword.text.trim(),
          );
      await AuthenticationRepository.instance.deleteAccount();
      TFullScreenLoader.stopLoading();
      Get.offAllNamed(TRoutes.onboarding);
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  void logout() {
    try {
      Get.defaultDialog(
        contentPadding: const EdgeInsets.all(TSizes.md),
        title: 'Logout',
        middleText: 'Are you sure you want to Logout?',
        confirm: ElevatedButton(
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
            child: Text('Confirm'),
          ),
          onPressed: () async {
            onClose();

            /// On Confirmation show any loader until user Logged Out.
            Get.defaultDialog(
              title: '',
              barrierDismissible: false,
              backgroundColor: Colors.transparent,
              content: const TCircularLoader(),
            );
            await AuthenticationRepository.instance.logout();
          },
        ),
        cancel: OutlinedButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        ),
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  void assignDataToProfile() {
    fullName.text = user.value.fullName;
    email.text = user.value.email;
    phoneNo.text = user.value.phoneNumber;
  }
}
