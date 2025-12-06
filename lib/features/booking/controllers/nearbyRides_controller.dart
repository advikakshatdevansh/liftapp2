import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/ride_model.dart';
import '../../../../data/repository/user_repository/user_repository.dart';
import '../../../../data/repository/notifications/authrepository.dart';
import '../../../personalization/models/user_model.dart';
import '../../chatting/controllers/chat_controller.dart';
import '../../chatting/controllers/chat_list_controller.dart';

class RiderDetailsController extends GetxController {
  final RideModel ride;
  RiderDetailsController(this.ride);

  var isLoading = true.obs;
  var user = Rxn<UserModel>();
  final chatListController = Get.put(ChatListController());

  @override
  void onInit() {
    super.onInit();
    fetchUser();
  }

  /// Fetch rider user info
  Future<void> fetchUser() async {
    try {
      user.value = await UserRepository.instance.getUserById(ride.userId);
    } catch (e) {
      Get.snackbar("Error", "Unable to load rider details");
    }
    isLoading.value = false;
  }

  /// Call rider
  Future<void> callUser(String phoneNumber) async {
    final Uri uri = Uri(scheme: "tel", path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("Error", "Unable to open dialer");
    }
  }

  /// Open chat or create one
  Future<void> messageUser() async {
    final currentUserId = AuthenticationRepository.instance.getUserID;

    final chatId = await chatListController.createOrGetChat(
      currentUserId,
      ride.userId,
    );

    Get.toNamed(
      "/chat",
      arguments: {
        "chatId": chatId,
        "currentUserId": currentUserId,
        "otherUserId": ride.userId,
        "otherUserName": ride.riderName,
      },
    );
  }

  String get formattedRideTime =>
      DateFormat('EEE, MMM d, yyyy \n hh:mm a').format(ride.createdAt);

  /// Send lift request
  void requestLift() async {
    final currentUserId = AuthenticationRepository.instance.getUserID;

    /// 1. Get or create chat
    final chatId = await chatListController.createOrGetChat(
      currentUserId,
      ride.userId,
    );

    /// 2. Build automatic message
    final autoMessage =
        '''
🚗 Lift Request Received!

A passenger has requested a lift for the following trip:

📍 From: ${ride.sourceName}
📌 To: ${ride.destinationName}
📏 Distance: ${ride.distanceKm.toStringAsFixed(2)} km
💰 Estimated Price: ₹${(ride.distanceKm * 6).toStringAsFixed(2)}
⏱ Departure Time: ${formattedRideTime}

Please confirm when you're available.
''';

    /// 3. Send message using ChatController
    final chatController = ChatController(chatId);
    await chatController.sendMessage(autoMessage, currentUserId);

    /// 4. Notify user
    Get.snackbar(
      "Request Sent",
      "A message has been sent to ${user.value?.fullName}",
    );
  }
}
