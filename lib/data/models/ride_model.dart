import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class RideModel {
  final String userId;
  final GeoPoint source;
  final GeoPoint destination;
  final String sourceName;
  final String destinationName;
  final double distanceKm;
  final DateTime createdAt;
  final String status;
  final int seatsAvailable;

  RideModel({
    required this.userId,
    required this.source,
    required this.destination,
    required this.sourceName,
    required this.destinationName,
    required this.distanceKm,
    required this.createdAt,
    required this.status,
    required this.seatsAvailable,
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
    "seatsAvailable": seatsAvailable,
    "sourceGeohash": GeoFirePoint(source).data['geohash'],
    "destinationGeohash": GeoFirePoint(destination).data['geohash'],
  };

  factory RideModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw Exception("Document data is null!");

    return RideModel(
      userId: data['userId'] ?? '',
      source: data['source'] as GeoPoint,
      destination: data['destination'] as GeoPoint,
      sourceName: data['sourceName'] ?? '',
      destinationName: data['destinationName'] ?? '',
      distanceKm: (data['distanceKm'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? '',
      seatsAvailable: data['seatsAvailable'] ?? 1,
    );
  }

  static RideModel empty() => RideModel(
    userId: '',
    source: const GeoPoint(0, 0),
    destination: const GeoPoint(0, 0),
    sourceName: '',
    destinationName: '',
    distanceKm: 0,
    createdAt: DateTime.now(),
    status: '',
    seatsAvailable: 1,
  );
}
