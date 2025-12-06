import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class LiftModel {
  final String userId;
  final Map<String, dynamic> source; // contains geopoint + geohash
  final Map<String, dynamic> destination; // contains geopoint + geohash
  final String sourceName;
  final String destinationName;
  final String lifterName;
  final double distanceKm;
  final DateTime createdAt;
  final String status;

  LiftModel({
    required this.userId,
    required this.source,
    required this.destination,
    required this.lifterName,
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
    "lifterName": lifterName,
    "sourceName": sourceName,
    "destinationName": destinationName,
    "distanceKm": distanceKm,
    "createdAt": createdAt,
    "status": status,
  };

  factory LiftModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw Exception("Lift document is null!");

    return LiftModel(
      userId: data['userId'] ?? '',
      source: Map<String, dynamic>.from(data['source'] ?? {}),
      destination: Map<String, dynamic>.from(data['destination'] ?? {}),
      lifterName: data['lifterName'] ?? '',
      sourceName: data['sourceName'] ?? '',
      destinationName: data['destinationName'] ?? '',
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? '',
    );
  }

  /// Empty model
  static LiftModel empty() => LiftModel(
    userId: "",
    source: {
      "geopoint": const GeoPoint(0, 0),
      "geohash": GeoFirePoint(const GeoPoint(0, 0)).geohash,
    },
    destination: {
      "geopoint": const GeoPoint(0, 0),
      "geohash": GeoFirePoint(const GeoPoint(0, 0)).geohash,
    },
    lifterName: '',
    sourceName: '',
    destinationName: '',
    distanceKm: 0,
    createdAt: DateTime.now(),
    status: "",
  );

  /// Helper for GeoFirePoint building
  factory LiftModel.withLocations({
    required String userId,
    required GeoPoint sourcePoint,
    required GeoPoint destinationPoint,
    required String sourceName,
    required String destinationName,
    required String lifterName,
    required double distanceKm,
    required String status,
  }) {
    return LiftModel(
      userId: userId,
      source: GeoFirePoint(sourcePoint).data,
      destination: GeoFirePoint(destinationPoint).data,
      sourceName: sourceName,
      destinationName: destinationName,
      lifterName: lifterName,
      distanceKm: distanceKm,
      createdAt: DateTime.now(),
      status: status,
    );
  }
}
