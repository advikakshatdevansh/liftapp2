import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class RideModel {
  final String userId;
  final Map<String, dynamic> source;
  final Map<String, dynamic> destination;
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

  /// Convert to JSON for Firestore
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
  };

  /// Create model from Firestore document
  factory RideModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw Exception("Document data is null!");

    return RideModel(
      userId: data['userId'] ?? '',
      source: Map<String, dynamic>.from(data['source'] ?? {}),
      destination: Map<String, dynamic>.from(data['destination'] ?? {}),
      sourceName: data['sourceName'] ?? '',
      destinationName: data['destinationName'] ?? '',
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? '',
      seatsAvailable: data['seatsAvailable'] ?? 1,
    );
  }

  /// Create a RideModel with empty/default values
  static RideModel empty() => RideModel(
    userId: '',
    source: {
      "geopoint": const GeoPoint(0, 0),
      "geohash": GeoFirePoint(const GeoPoint(0, 0)).geohash,
    },
    destination: {
      "geopoint": const GeoPoint(0, 0),
      "geohash": GeoFirePoint(const GeoPoint(0, 0)).geohash,
    },
    sourceName: '',
    destinationName: '',
    distanceKm: 0,
    createdAt: DateTime.now(),
    status: '',
    seatsAvailable: 1,
  );

  /// Helper for creating a RideModel with coordinates
  factory RideModel.withLocations({
    required String userId,
    required GeoPoint sourcePoint,
    required GeoPoint destinationPoint,
    required String sourceName,
    required String destinationName,
    required double distanceKm,
    required String status,
    required int seatsAvailable,
  }) {
    return RideModel(
      userId: userId,
      source: GeoFirePoint(sourcePoint).data,
      destination: GeoFirePoint(destinationPoint).data,
      sourceName: sourceName,
      destinationName: destinationName,
      distanceKm: distanceKm,
      createdAt: DateTime.now(),
      status: status,
      seatsAvailable: seatsAvailable,
    );
  }
}
