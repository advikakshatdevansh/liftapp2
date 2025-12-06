import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  /// NEW
  final String messageType; // "text" | "ride_request"
  final Map<String, dynamic>? rideRequest;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.messageType = "text",
    this.rideRequest,
  });

  factory MessageModel.fromMap(Map<String, dynamic> data, String id) {
    return MessageModel(
      id: id,
      senderId: data['senderId'],
      text: data['text'] ?? "",
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      messageType: data['messageType'] ?? "text",
      rideRequest: data['rideRequest'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'messageType': messageType,
      'rideRequest': rideRequest,
    };
  }
}
