import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../models/lift_model.dart';

class LiftRepository extends GetxController {
  static LiftRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  /// Create Lift using GeoFirePoint
  Future<void> createLift({
    required String userId,
    required LatLng source,
    required LatLng destination,
    required String lifterName,
    required String sourceName,
    required String destinationName,
    required double distanceKm,
    String status = "active",
  }) async {
    try {
      final sourceGeo = GeoFirePoint(
        GeoPoint(source.latitude, source.longitude),
      );
      final destGeo = GeoFirePoint(
        GeoPoint(destination.latitude, destination.longitude),
      );

      final lift = LiftModel(
        userId: userId,
        source: sourceGeo.data,
        destination: destGeo.data,
        sourceName: sourceName,
        destinationName: destinationName,
        lifterName: lifterName,
        distanceKm: distanceKm,
        createdAt: DateTime.now(),
        status: status,
      );

      await _db.collection("Lifts").add(lift.toJson());
    } catch (e) {
      throw 'Error creating lift: $e';
    }
  }

  /// Get All Lifts created by user
  Future<List<LiftModel>> getUserLifts(String userId) async {
    try {
      final query = await _db
          .collection("Lifts")
          .where("userId", isEqualTo: userId)
          .get();

      return query.docs.map((doc) => LiftModel.fromDoc(doc)).toList();
    } catch (e) {
      throw 'Error fetching user lifts: $e';
    }
  }

  /// Find lifts by radius from source + destination
  Future<List<LiftModel>> findLifts({
    required LatLng source,
    required LatLng destination,
    double radius = 10,
  }) async {
    try {
      final liftsRef = _db
          .collection("Lifts")
          .withConverter<LiftModel>(
            fromFirestore: (snap, _) => LiftModel.fromDoc(snap),
            toFirestore: (model, _) => model.toJson(),
          );

      final geoCollection = GeoCollectionReference<LiftModel>(liftsRef);

      final nearbySource = await geoCollection.fetchWithinWithDistance(
        center: GeoFirePoint(GeoPoint(source.latitude, source.longitude)),
        radiusInKm: radius,
        field: 'source',
        geopointFrom: (lift) => lift.source['geopoint'] as GeoPoint,
        strictMode: false,
      );

      final destCenter = GeoFirePoint(
        GeoPoint(destination.latitude, destination.longitude),
      );

      final List<LiftModel> match = [];

      for (final snapshot in nearbySource) {
        final lift = snapshot.documentSnapshot.data();
        if (lift == null) continue;

        final destPoint = lift.destination['geopoint'] as GeoPoint;
        final dist = destCenter.distanceBetweenInKm(geopoint: destPoint);

        if (dist <= radius) match.add(lift);
      }

      return match;
    } catch (e) {
      throw 'Error finding lifts: $e';
    }
  }

  /// Get only source locations (LatLng)
  Future<List<LatLng>> getAllLiftSources({
    required LatLng source,
    required LatLng destination,
    double radius = 10,
  }) async {
    try {
      final lifts = await findLifts(
        source: source,
        destination: destination,
        radius: radius,
      );

      return lifts.map((lift) {
        final GeoPoint gp = lift.source['geopoint'];
        return LatLng(gp.latitude, gp.longitude);
      }).toList();
    } catch (e) {
      throw 'Error fetching lift sources: $e';
    }
  }

  /// Add dummy lifts
  Future<void> addDummyLifts() async {
    final data = [
      LatLng(30.3601, 78.0718),
      LatLng(30.3610, 78.0725),
      LatLng(30.3608, 78.0714),
      LatLng(30.3599, 78.0719),
    ];

    for (final src in data) {
      await createLift(
        userId: "dummyUser",
        source: src,
        destination: LatLng(30.3677, 78.0783),
        lifterName: "dummy",
        sourceName: "Dummy Src",
        destinationName: "Dummy Dest",
        distanceKm: 3,
      );
    }
  }
}
