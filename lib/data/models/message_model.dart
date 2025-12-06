// In: '../../../data/models/message_model.dart'

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id; // Added field for document ID
  final String senderId;
  final String text;
  final DateTime timestamp;

  MessageModel({
    required this.id, // ID is now required
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  // Updated factory method to accept two positional arguments: data and id
  factory MessageModel.fromMap(Map<String, dynamic> data, String id) {
    // Handling timestamp conversion: Firestore stores it as a Timestamp object
    final Timestamp firestoreTimestamp = data['timestamp'] as Timestamp? ?? Timestamp.now();

    return MessageModel(
      id: id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: firestoreTimestamp.toDate(),
    );
  }
}