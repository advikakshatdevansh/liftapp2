import 'package:cloud_firestore/cloud_firestore.dart';

class LiftModel {
  final String userId;
  final GeoPoint source;
  final GeoPoint destination;
  final String sourceName;
  final String destinationName;
  final double distanceKm;
  final DateTime createdAt;
  final String status;

  LiftModel({
    required this.userId,
    required this.source,
    required this.destination,
    required this.sourceName,
    required this.destinationName,
    required this.distanceKm,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "source": source,
    "destination": destination,
    "sourceName": sourceName,
    "destinationName": destinationName,
    "distanceKm": distanceKm,
    "createdAt": createdAt,
    "status": status,
  };

  factory LiftModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LiftModel(
      userId: data["userId"],
      source: data["source"],
      sourceName: data["sourceName"],
      destinationName: data["destinationName"],
      destination: data["destination"],
      distanceKm: data["distanceKm"]?.toDouble() ?? 0.0,
      createdAt: (data["createdAt"] as Timestamp).toDate(),
      status: data["status"] ?? "requested",
    );
  }

  static LiftModel empty() => LiftModel(
    userId: "",
    source: GeoPoint(0, 0),
    destination: GeoPoint(0, 0),
    distanceKm: 0,
    createdAt: DateTime.now(),
    status: "",
    sourceName: '',
    destinationName: '',
  );
}
