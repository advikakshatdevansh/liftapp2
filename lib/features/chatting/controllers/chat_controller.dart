import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import '../../../data/models/message_model.dart';
import '../../../data/repository/notifications/authrepository.dart';
import 'package:url_launcher/url_launcher.dart';

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
          final newMessages = snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList();

          messages.value = newMessages;

          if (newMessages.isNotEmpty) {
            final msg = newMessages.first;

            if (msg.requestType == MessageType.requestAccepted.name) {
              _onRideAccepted();

              // If UPI ID exists → redirect user to payment screen
              if (msg.upiId != null && msg.upiId!.isNotEmpty) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  launchUPIPayment(
                    upiId: msg.upiId!,
                    payeeName: "Driver",
                    amount: "50", // or dynamic based on ride
                  );
                });
              }
            }
          }
        });
  }

  void _onRideAccepted() {
    print("Rider accepted your request!");

    Get.snackbar(
      "Request Accepted",
      "The rider has accepted your lift request 🎉",
      snackPosition: SnackPosition.TOP,
    );
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

  // 1. Update the arguments to accept 'upiId'
  Future<void> acceptRideRequest(MessageModel msg, String upiId) async {
    if (msg.rideId.isEmpty) {
      return;
    }

    final rideRef = FirebaseFirestore.instance
        .collection("Rides")
        .doc(msg.rideId);

    try {
      // --- SUCCESS LOGIC ---
      await _sendSystemReply(
        text: "Your lift request has been accepted 🎉",
        systemType: MessageType.requestAccepted,
        upiId: upiId,
      );

      // 3. Delete the original request message
      await deleteMessage(msg);
    } catch (e) {
      print("Error accepting ride: $e");
      Get.snackbar("Error", "Could not accept ride: $e");
    }
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
    required MessageType systemType,
    String? upiId, // <--- Optional parameter
  }) async {
    final msgRef = FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    // Prepare data
    final Map<String, dynamic> data = {
      'senderId': 'system',
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'messageType': systemType.name,
    };

    // If UPI ID is provided, add it to the message data
    if (upiId != null && upiId.isNotEmpty) {
      data['upiId'] = upiId;
    }

    await msgRef.set(data);

    await FirebaseFirestore.instance.collection('Chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': 'system',
    });
  }

  Future<void> launchUPIPayment({
    required String upiId,
    required String payeeName,
    required String amount,
    String transactionNote = "Lift payment",
  }) async {
    final uri = Uri.parse(
      "upi://pay"
      "?pa=$upiId"
      "&pn=$payeeName"
      "&tn=$transactionNote"
      "&am=$amount"
      "&cu=INR",
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw "Could not launch UPI app";
    }
  }
}
