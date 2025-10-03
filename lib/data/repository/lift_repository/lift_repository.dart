import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../models/lift_model.dart';

class LiftRepository extends GetxController {
  static LiftRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  Future<void> createLift(LiftModel lift) async {
    try {
      await _db.collection("Lifts").add(lift.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<LiftModel>> getUserLifts(String userId) async {
    try {
      final querySnapshot = await _db
          .collection("Lifts")
          .where("userId", isEqualTo: userId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.map((doc) => LiftModel.fromDoc(doc)).toList();
      } else {
        return [];
      }
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}
