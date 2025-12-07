// In message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, requestRide, requestAccepted, requestRejected }

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageType requestType;
  final String requestStatus;
  final String rideId;
  final String upiId; // <--- 1. NEW FIELD

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.requestType,
    required this.requestStatus,
    this.rideId = '',
    this.upiId = '', // <--- Initialize
  });

  factory MessageModel.fromMap(Map<String, dynamic> data, String id) {
    final Timestamp firestoreTimestamp =
        data['timestamp'] as Timestamp? ?? Timestamp.now();

    return MessageModel(
      id: id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: firestoreTimestamp.toDate(),
      requestType: MessageType.values.firstWhere(
        (e) => e.name == data['requestType'],
        orElse: () => MessageType.text,
      ),
      requestStatus: data['requestStatus'] as String? ?? '',
      rideId: data['rideId'] as String? ?? '',
      upiId: data['upiId'] as String? ?? '', // <--- Map from Firestore
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'text': text,
    'requestType': requestType.name,
    "requestStatus": requestStatus,
    'timestamp': Timestamp.fromDate(timestamp),
    'rideId': rideId,
    'upiId': upiId, // <--- Save to Firestore
  };
}
