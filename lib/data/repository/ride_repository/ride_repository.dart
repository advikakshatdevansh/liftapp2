import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
}
