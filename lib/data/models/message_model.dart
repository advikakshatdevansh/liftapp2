// In message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, requestRide, requestAccepted, requestRejected }

class MessageModel {
  final String id; // This MUST be the Firestore document ID
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageType requestType;
  final String requestStatus;
  final String rideId; // <-- NEW FIELD for the ride ID

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.requestType,
    required this.requestStatus,
    this.rideId = '', // Initialize to empty string
  });

  // Updated factory method:
  factory MessageModel.fromMap(Map<String, dynamic> data, String id) {
    final Timestamp firestoreTimestamp =
        data['timestamp'] as Timestamp? ?? Timestamp.now();

    return MessageModel(
      id: id, // <-- The correct document ID
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: firestoreTimestamp.toDate(),
      requestType: MessageType.values.firstWhere(
        (e) => e.name == data['requestType'],
        orElse: () => MessageType.text,
      ),
      requestStatus: data['requestStatus'] as String? ?? '',
      rideId: data['rideId'] as String? ?? '', // <-- Read new field
    );
  }

  // toMap and toJson methods can be cleaned up:
  Map<String, dynamic> toMap() => {
    // 'id' should generally not be saved in the document data, as it's the doc name
    'senderId': senderId,
    'text': text,
    'requestType': requestType.name,
    "requestStatus": requestStatus,
    // When sending: use FieldValue.serverTimestamp() instead of DateTime
    'timestamp': Timestamp.fromDate(timestamp),
    'rideId': rideId,
  };
}
