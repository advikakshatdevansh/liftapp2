import 'package:get/get.dart';
import 'package:liftapp2/data/repository/lift_repository/lift_repository.dart';
import '../data/repository/notifications/authrepository.dart';
import '../data/services/notifications/notification_service.dart';
import '../features/authentication/controllers/login_controller.dart';
import '../features/authentication/controllers/on_boarding_controller.dart';
import '../features/authentication/controllers/otp_controller.dart';
import '../features/authentication/controllers/signup_controller.dart';
import '../features/booking/controllers/location_controller.dart';
import '../personalization/controllers/active_lifts_controller.dart';
import '../personalization/controllers/address_controller.dart';
import '../personalization/controllers/notification_controller.dart';
import '../personalization/controllers/theme_controller.dart';
import '../personalization/controllers/user_controller.dart';
import '../utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    /// -- Core
    Get.put(NetworkManager());

    /// -- Repository
    Get.lazyPut(() => AuthenticationRepository(), fenix: true);
    // Get.put(CartController());
    Get.put(ThemeController());
    // Get.put(ProductController());
    Get.lazyPut(() => UserController());
    Get.lazyPut(() => ActiveLiftsController(), fenix: true);
    Get.lazyPut(() => LiftRepository(), fenix: true);
    Get.lazyPut(() => AddressController());
    Get.lazyPut(() => LocationsController(), fenix: true);
    Get.lazyPut(() => OnBoardingController(), fenix: true);

    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => SignUpController(), fenix: true);
    Get.lazyPut(() => OTPController(), fenix: true);
    Get.put(TNotificationService());
    Get.lazyPut(() => NotificationController(), fenix: true);
  }
}
