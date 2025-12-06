import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Import for StreamSubscription
import 'package:intl/intl.dart'; // REQUIRED: Add 'intl: ^[latest_version]' to pubspec.yaml

import '../../../data/models/message_model.dart';

class ChatController extends GetxController {
  final String chatId;
  ChatController(this.chatId);

  var messages = <MessageModel>[].obs;
  late StreamSubscription<QuerySnapshot> _messageSubscription;

  @override
  void onInit() {
    super.onInit();
    // 1. Initialize the listener and subscribe to the stream
    _messageSubscription = FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      messages.value = snapshot.docs
      // Assuming MessageModel.fromMap takes data and id
          .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // 2. VITAL FIX: Add the formatTime method
  String formatTime(DateTime time) {
    // This formats the DateTime object into a clean 'h:mm a' format (e.g., 3:30 PM)
    return DateFormat('h:mm a').format(time.toLocal());
    // .toLocal() is good practice since Firestore Timestamps are often UTC
  }

  @override
  void onClose() {
    // 3. Prevent memory leak by cancelling the stream
    _messageSubscription.cancel();
    super.onClose();
  }

  Future<void> sendMessage(String message, String senderId) async {
    if (message.trim().isEmpty) {
      return;
    }

    final messageText = message.trim();

    // Use a WriteBatch for atomic updates (message and chat metadata)
    final batch = FirebaseFirestore.instance.batch();

    // A. Reference and data for the new message
    final msgRef = FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    batch.set(msgRef, {
      'senderId': senderId,
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // B. Update the parent chat document
    final chatRef = FirebaseFirestore.instance.collection('Chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': messageText,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': senderId,
    });

    // Commit the batch
    await batch.commit();
  }
}