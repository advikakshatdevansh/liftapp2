import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/message_model.dart';

class ChatController extends GetxController {
  final String chatId;
  ChatController(this.chatId);

  var messages = <MessageModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          messages.value = snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> sendMessage(String message, String senderId) async {
    final msgRef = FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    await msgRef.set({
      'senderId': senderId,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('Chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': senderId,
    });
  }
}
