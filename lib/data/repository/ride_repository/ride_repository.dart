import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../models/ride_model.dart';
import '../notifications/authrepository.dart';

class RideRepository extends GetxController {
  static RideRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  /// ✅ Create a new ride with proper GeoFire structure
  Future<void> createRide({
    required String userId,
    required LatLng source,
    required LatLng destination,
    required String riderName,
    required String sourceName,
    required String destinationName,
    required double distanceKm,
    String status = "active",
    int seatsAvailable = 3,
  }) async {
    try {
      // Convert to GeoFire data
      final sourceGeo = GeoFirePoint(
        GeoPoint(source.latitude, source.longitude),
      );
      final destGeo = GeoFirePoint(
        GeoPoint(destination.latitude, destination.longitude),
      );

      final ride = RideModel(
        userId: userId,
        source: sourceGeo.data,
        destination: destGeo.data,
        sourceName: sourceName,
        destinationName: destinationName,
        riderName: riderName,
        distanceKm: distanceKm,
        createdAt: DateTime.now(),
        status: status,
        seatsAvailable: seatsAvailable,
      );

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

  /// ✅ Fetch rides created by a specific user
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

  /// ✅ NEW: Fetch the SOURCE locations of all available rides as LatLng list
  Future<List<LatLng>> getAllRideSources({
    required LatLng source,
    required LatLng destination,
    double radius = 10,
  }) async {
    try {
      final rides = await findRides(
        source: source,
        destination: destination,
        radius: radius,
      );

      final List<LatLng> sources = rides.map((ride) {
        final GeoPoint geo = ride.source['geopoint'] as GeoPoint;
        return LatLng(geo.latitude, geo.longitude);
      }).toList();
      print("returned alll rides sources");
      return sources;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while fetching ride sources: $e';
    }
  }

  Future<List<RideModel>> findRides({
    required LatLng source,
    required LatLng destination,
    double radius = 10,
  }) async {
    try {
      final ridesRef = _db
          .collection("Rides")
          .withConverter<RideModel>(
            fromFirestore: (snap, _) => RideModel.fromDoc(snap),
            toFirestore: (ride, _) => ride.toJson(),
          );

      final geoCollection = GeoCollectionReference<RideModel>(ridesRef);

      final nearbySourceRides = await geoCollection.fetchWithinWithDistance(
        center: GeoFirePoint(GeoPoint(source.latitude, source.longitude)),
        radiusInKm: radius,
        field: 'source',
        geopointFrom: (ride) => (ride.source['geopoint'] as GeoPoint),
        strictMode: false,
      );

      final destinationCenter = GeoFirePoint(
        GeoPoint(destination.latitude, destination.longitude),
      );

      final List<RideModel> matchingRides = [];

      for (final rideSnapshot in nearbySourceRides) {
        final ride = rideSnapshot.documentSnapshot.data();
        if (ride == null) continue;

        final destPoint = ride.destination['geopoint'] as GeoPoint;
        final destDistance = destinationCenter.distanceBetweenInKm(
          geopoint: destPoint,
        );

        if (destDistance <= radius) {
          matchingRides.add(ride);
        }
      }

      return matchingRides;
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

  Future<void> addDummyRides() async {
    final List<Map<String, dynamic>> dummyRides = [
      {
        "source": LatLng(30.3601, 78.0718),
        "destination": LatLng(30.3676, 78.0780),
      },
      {
        "source": LatLng(30.3610, 78.0725),
        "destination": LatLng(30.3679, 78.0779),
      },
      {
        "source": LatLng(30.3608, 78.0714),
        "destination": LatLng(30.3680, 78.0782),
      },
      {
        "source": LatLng(30.3599, 78.0719),
        "destination": LatLng(30.3677, 78.0783),
      },
    ];

    final userId = "dummyUser123"; // or your logged in user ID

    for (final ride in dummyRides) {
      final sourceGeo = GeoFirePoint(
        GeoPoint(ride["source"].latitude, ride["source"].longitude),
      );
      final destGeo = GeoFirePoint(
        GeoPoint(ride["destination"].latitude, ride["destination"].longitude),
      );

      final rideData = {
        "userId": userId,
        "source": sourceGeo.data,
        "destination": destGeo.data,
        "sourceName": "Dummy Source",
        "destinationName": "Dummy Destination",
        "distanceKm": 2.5,
        "createdAt": DateTime.now(),
        "status": "active",
        "seatsAvailable": 3,
      };

      await _db.collection("Rides").add(rideData);
    }

    print("✅ Dummy rides with GeoFire data added successfully!");
  }
}
