import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, requestRide, requestAccepted, requestRejected }

class MessageModel {
  final String id; // Added field for document ID
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageType requestType; // "liftRequest"
  final String requestStatus; // "pending", "accepted", "rejected"

  MessageModel({
    required this.id, // ID is now required
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.requestType,
    required this.requestStatus,
  });

  // Updated factory method to accept two positional arguments: data and id
  factory MessageModel.fromMap(Map<String, dynamic> data, String id) {
    // Handling timestamp conversion: Firestore stores it as a Timestamp object
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
    );
  }
  Map<String, dynamic> toJson() => {
    "id": id,
    "senderId": senderId,
    "text": text,
    "timestamp": timestamp,
    "requestType": requestType.name,
    "requestStatus": requestStatus,
  };
  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'text': text,
    'requestType': requestType.name,
    "requestStatus": requestStatus,
    'timestamp': timestamp,
    'id': id,
  };
}
