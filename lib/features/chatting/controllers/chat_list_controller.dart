import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liftapp2/data/repository/notifications/authrepository.dart';
import '../../../data/models/chat_model.dart';

class ChatListController extends GetxController {
  var chats = <ChatModel>[].obs;
  final userNames = <String, String>{}.obs; // userId → fullName
  final userPhotos = <String, String>{}.obs; // userId → profilePicture

  final currentUserId = AuthenticationRepository
      .instance
      .getUserID; // Replace with your Auth user ID

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

  Future<String> createOrGetChat(String user1, String user2) async {
    final chatQuery = await FirebaseFirestore.instance
        .collection('Chats')
        .where('participants', arrayContains: user1)
        .get();

    // Check if chat exists
    for (var doc in chatQuery.docs) {
      List participants = doc['participants'];
      if (participants.contains(user2)) {
        return doc.id; // chat already exists
      }
    }

    // Create new chat
    final newChatRef = FirebaseFirestore.instance.collection('Chats').doc();

    await newChatRef.set({
      'participants': [user1, user2],
      'lastMessage': 'Hi',
      'lastMessageSenderId': user1,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    // Send first hi message
    await newChatRef.collection('messages').add({
      'senderId': user1,
      'text': 'Hi',
      'timestamp': FieldValue.serverTimestamp(),
    });

    return newChatRef.id;
  }
}
