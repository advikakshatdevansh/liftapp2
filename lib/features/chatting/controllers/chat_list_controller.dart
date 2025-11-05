import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/chat_model.dart';

class ChatListController extends GetxController {
  var chats = <ChatModel>[].obs;
  final userNames = <String, String>{}.obs; // userId → fullName
  final userPhotos = <String, String>{}.obs; // userId → profilePicture

  final currentUserId =
      "zJGH7iwQeOWQunMCOry5ZYFhqM2"; // Replace with your Auth user ID

  @override
  void onInit() {
    super.onInit();
    FirebaseFirestore.instance
        .collection('Chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .listen((snapshot) async {
          chats.value = snapshot.docs
              .map((doc) => ChatModel.fromMap(doc.data(), doc.id))
              .toList();

          // Fetch names for all other participants
          for (var chat in chats) {
            String otherUserId = chat.participants.firstWhere(
              (id) => id != currentUserId,
            );
            await _loadUserInfo(otherUserId);
          }

          // Sort by last message time
          chats.sort(
            (a, b) => (b.lastMessageTime ?? DateTime.now()).compareTo(
              a.lastMessageTime ?? DateTime.now(),
            ),
          );
        });
  }

  Future<void> _loadUserInfo(String userId) async {
    if (userNames.containsKey(userId)) return; // already loaded

    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();
    if (doc.exists) {
      userNames[userId] = doc.data()?['fullName'] ?? "Unknown User";
      userPhotos[userId] = doc.data()?['profilePicture'] ?? "";
    }
  }

  String getOtherUserId(ChatModel chat) {
    return chat.participants.firstWhere((id) => id != currentUserId);
  }

  String getOtherUserName(String userId) {
    return userNames[userId] ?? "Loading...";
  }

  String getOtherUserPhoto(String userId) {
    return userPhotos[userId] ?? "";
  }
}
