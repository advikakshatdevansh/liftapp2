import 'package:get/get.dart';
import 'package:liftapp2/features/authentication/screens/on_boarding/on_boarding_screen.dart';
import 'package:liftapp2/features/authentication/screens/signup/signup_screen.dart';
import 'package:liftapp2/features/authentication/screens/welcome/welcome_screen.dart';
import 'package:liftapp2/main.dart';
import 'package:liftapp2/personalization/screens/notification/notification_screen.dart';
import 'package:liftapp2/personalization/screens/profile/re_authenticate_phone_otp_screen.dart';
import '../bindings/notification_binding.dart';
import '../features/authentication/screens/forget_password/forget_password_otp/otp_screen.dart';
import '../features/authentication/screens/login/login_screen.dart';
import '../features/booking/screens/selectLocation/select_location_screen.dart';
import '../personalization/screens/notification/notification_detail_screen.dart';
import '../personalization/screens/profile/profile_screen.dart';

class TRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const signupstep1 = '/signupstep1';
  static const signupstep3 = '/signupstep3';
  static const home = '/home';
  static const homeTab = '/homeTab';
  static const search = '/search';
  static const profile = '/profile';

  static const likes = '/likes';
  static const phonenumber = '/phone';
  static const uitest = '/uitest';
  static const namedob = '/namedob';
  static const map = '/map';
  static const booking = '/booking';

  static const welcome = '/welcome-screen';
  static const onboarding = '/onboarding-screen';
  static const selectLocation = '/courses-dashboard-screen';
  static const eComDashboard = '/eCom-dashboard-screen';

  static const logIn = '/log-in';
  static const phoneSignIn = '/phone-sign-in';
  static const otpVerification = '/otp-verification';
  static const reAuthenticateOtpVerification =
      '/re-authenticate-otp-verification';
  static const profileScreen = '/profile-screen';
  static const cartScreen = '/cart-screen';
  static const checkoutScreen = '/checkout-screen';
  static const favouritesScreen = '/favourites-screen';

  //Notification
  static const notification = '/notification';
  static const notificationDetails = '/notification-details';

  static final pages = [
    GetPage(name: TRoutes.login, page: () => LoginScreen()),
    GetPage(name: TRoutes.signup, page: () => SignupScreen()),
    GetPage(name: TRoutes.welcome, page: () => const WelcomeScreen()),
    GetPage(name: TRoutes.onboarding, page: () => const OnBoardingScreen()),
    GetPage(name: TRoutes.selectLocation, page: () => const SelectLocation()),
    GetPage(name: TRoutes.eComDashboard, page: () => const MyHomePage()),
    GetPage(name: TRoutes.home, page: () => const SelectLocation()),
    GetPage(name: TRoutes.phoneSignIn, page: () => const MyHomePage()),
    GetPage(name: TRoutes.otpVerification, page: () => const OTPScreen()),
    GetPage(
      name: TRoutes.reAuthenticateOtpVerification,
      page: () => const ReAuthenticatePhoneOtpScreen(),
    ),
    GetPage(name: TRoutes.profileScreen, page: () => const ProfileScreen()),
    GetPage(name: TRoutes.cartScreen, page: () => const MyHomePage()),
    GetPage(name: TRoutes.checkoutScreen, page: () => const MyHomePage()),
    GetPage(name: TRoutes.favouritesScreen, page: () => const MyHomePage()),

    GetPage(
      name: TRoutes.notification,
      page: () => const NotificationScreen(),
      binding: NotificationBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: TRoutes.notificationDetails,
      page: () => const NotificationDetailScreen(),
      binding: NotificationBinding(),
      transition: Transition.fade,
    ),
  ];
}

// class AppRoutes {
//   static final pages = [
//     GetPage(name: TRoutes.welcome, page: () => const WelcomeScreen()),
//     GetPage(name: TRoutes.onboarding, page: () => const OnBoardingScreen()),
//     GetPage(name: TRoutes.coursesDashboard, page: () => const CoursesDashboard()),
//     GetPage(name: TRoutes.eComDashboard, page: () => const HomeScreen()),
//
//     GetPage(name: TRoutes.phoneSignIn, page: () => const PhoneNumberScreen()),
//     GetPage(name: TRoutes.otpVerification, page: () => const PhoneOtpScreen()),
//     GetPage(name: TRoutes.reAuthenticateOtpVerification, page: () => const ReAuthenticatePhoneOtpScreen()),
//     GetPage(name: TRoutes.cartScreen, page: () => const CartScreen()),
//     GetPage(name: TRoutes.checkoutScreen, page: () => const CheckoutScreen()),
//     GetPage(name: TRoutes.favouritesScreen, page: () => const FavouriteScreen()),
//
//     GetPage(name: TRoutes.notification, page: () => const NotificationScreen(), binding: NotificationBinding(), transition: Transition.fade),
//     GetPage(name: TRoutes.notificationDetails, page: () => const NotificationDetailScreen(), binding: NotificationBinding(), transition: Transition.fade),
//   ];
// }
