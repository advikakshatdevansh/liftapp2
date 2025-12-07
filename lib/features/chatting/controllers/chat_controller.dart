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
    // Use a map directly for clarity when using .add()
    final msgData = {
      'senderId': AuthenticationRepository.instance.getUserID,
      'text': message, // e.g., "User requested 1 seat for your ride"
      'timestamp': FieldValue.serverTimestamp(),
      'requestType': MessageType.requestRide.name,
      'requestStatus': 'pending', // Use 'pending' for initial status
      'rideId': rideId, // <-- NEW FIELD for the ride ID
      'seatsRequested': seatsRequested,
    };

    // .add() automatically generates the document ID which is handled by the stream
    await FirebaseFirestore.instance
        .collection("Chats")
        .doc(chatId)
        .collection("messages")
        .add(msgData);

    // Update last message in chat document
    await FirebaseFirestore.instance.collection('Chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': AuthenticationRepository.instance.getUserID,
    });
  }

  // In ChatController

  Future<void> acceptRideRequest(MessageModel msg) async {
    // 1. Send the system reply
    await _sendSystemReply(
      text: "Your lift request has been accepted 🎉",
      systemType: MessageType.requestAccepted,
      // Optional: you can pass the ride ID here if the system reply is tied to a ride
    );

    // 2. Decrement seats in the Ride document
    // NOTE: msg.rideId is now used for the Ride document ID
    if (msg.rideId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("Rides")
          .doc(msg.rideId)
          .update({"seatsAvailable": FieldValue.increment(-1)});
    }

    // 3. Delete the original request message
    // NOTE: msg.id is now the Firestore document ID for the message
    await deleteMessage(msg);
  }

  Future<void> rejectRideRequest(MessageModel msg) async {
    // 1. Send the system reply
    await _sendSystemReply(
      text: "Your lift request was rejected ❌",
      systemType: MessageType.requestRejected,
    );

    // 2. Delete the original request message
    // NOTE: msg.id is now the Firestore document ID for the message
    await deleteMessage(msg);
  }

  /// ---------------------------
  /// Delete a message by its document id.
  /// ---------------------------
  Future<void> deleteMessage(MessageModel msg) async {
    try {
      // This is now guaranteed to be the document ID from the stream
      final ref = FirebaseFirestore.instance
          .collection('Chats')
          .doc(chatId)
          .collection('messages')
          .doc(msg.id); // <-- This now uses the correct Firestore doc ID
      await ref.delete();
    } catch (e) {
      print('deleteMessage error: $e');
    }
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
}
