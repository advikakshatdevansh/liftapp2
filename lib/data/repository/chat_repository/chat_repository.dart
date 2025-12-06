import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ChatRepository extends GetxController {
  static ChatRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;
}
