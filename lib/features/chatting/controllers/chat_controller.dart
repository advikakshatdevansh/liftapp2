import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Import for StreamSubscription
import 'package:intl/intl.dart'; // REQUIRED: Add 'intl: ^[latest_version]' to pubspec.yaml

import '../../../data/models/message_model.dart';
import '../../../data/repository/notifications/authrepository.dart';

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

  Future<void> sendRideRequest({
    required String rideId,
    required int seatsRequested,
    required String message,
  }) async {
    final msg = MessageModel(
      senderId: AuthenticationRepository.instance.getUserID,
      text: message,
      timestamp: DateTime.now(),
      requestType: MessageType.requestRide,
      id: rideId,
      requestStatus: 'none',
    );
    final currentUserId = AuthenticationRepository.instance.getUserID;
    await FirebaseFirestore.instance
        .collection("Chats")
        .doc(chatId)
        .collection("messages")
        .add(msg.toMap());
  }

  Future<void> acceptRideRequest(MessageModel msg) async {
    await _sendSystemReply(
      text: "Your lift request has been accepted 🎉",
      systemType: MessageType.requestAccepted,
    );

    await FirebaseFirestore.instance.collection("Rides").doc(msg.id).update({
      "seatsAvailable": FieldValue.increment(-1),
    });

    await deleteMessage(msg);
  }

  Future<void> rejectRideRequest(MessageModel msg) async {
    await _sendSystemReply(
      text: "Your lift request was rejected ❌",
      systemType: MessageType.requestRejected,
    );

    await deleteMessage(msg);
  }

  Future<void> _sendSystemReply({
    required String text,
    required MessageType
    systemType, // e.g. 'requestAccepted' or 'requestRejected'
  }) async {
    final msgRef = FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    await msgRef.set({
      'senderId': 'system',
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'messageType': systemType,
    });

    await FirebaseFirestore.instance.collection('Chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': 'system',
    });
  }

  /// ---------------------------
  /// Delete a message by its document id. If msg.id is empty, fallback to timestamp query.
  /// ---------------------------
  Future<void> deleteMessage(MessageModel msg) async {
    try {
      if (msg.id.isNotEmpty) {
        final ref = FirebaseFirestore.instance
            .collection('Chats')
            .doc(chatId)
            .collection('messages')
            .doc(msg.id);
        await ref.delete();
        return;
      }

      // Fallback: find by timestamp + senderId (less ideal)
      final q = await FirebaseFirestore.instance
          .collection('Chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isEqualTo: msg.senderId)
          .where('text', isEqualTo: msg.text)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      for (var doc in q.docs) {
        // crude match; you can improve with timestamp equality if stored as ISO string
        await doc.reference.delete();
      }
    } catch (e) {
      // handle error / log
      print('deleteMessage error: $e');
    }
  }
}
