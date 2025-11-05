import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../models/ride_model.dart';

class RideRepository extends GetxController {
  static RideRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  Future<void> createRide(RideModel ride) async {
    try {
      await _db.collection("Rides").add(ride.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (_) {
      throw 'Something went wrong while creating ride';
    }
  }

  Future<List<RideModel>> getUserRides(String userId) async {
    try {
      final snapshot = await _db
          .collection("Rides")
          .where("userId", isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) => RideModel.fromDoc(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (_) {
      throw 'Something went wrong while fetching rides';
    }
  }

  /// Find rides near a given source and destination within a radius (km)
  Future<List<LatLng>> findRides(
    LatLng source,
    LatLng destination,
    double radius,
  ) async {
    try {
      final ridesRef = _db
          .collection("Rides")
          .withConverter<RideModel>(
            fromFirestore: (snap, _) => RideModel.fromDoc(snap),
            toFirestore: (ride, _) => ride.toJson(),
          );

      final geoCollection = GeoCollectionReference<RideModel>(ridesRef);

      /// Query 1: Find rides whose source is near user's source
      final nearbySourceRides = await geoCollection.fetchWithinWithDistance(
        center: GeoFirePoint(GeoPoint(source.latitude, source.longitude)),
        radiusInKm: radius,
        field: 'source',
        geopointFrom: (ride) => ride.source,
        strictMode: false,
      );

      final List<LatLng> nearbyRideMarkers = [];

      final destinationCenter = GeoFirePoint(
        GeoPoint(destination.latitude, destination.longitude),
      );

      // 2️⃣ Filter those rides whose DESTINATION is also near user's destination
      for (final rideSnapshot in nearbySourceRides) {
        final ride = rideSnapshot.documentSnapshot.data();
        if (ride == null) continue;

        final destDistance = destinationCenter.distanceBetweenInKm(
          geopoint: ride.destination,
        );

        if (destDistance <= radius) {
          // Add the rider’s SOURCE LatLng to the map points list
          nearbyRideMarkers.add(
            LatLng(ride.source.latitude, ride.source.longitude),
          );
        }
      }

      return nearbyRideMarkers;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while finding rides: $e';
    }
  }
}
