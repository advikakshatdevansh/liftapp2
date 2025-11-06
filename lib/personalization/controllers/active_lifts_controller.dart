import 'package:get/get.dart';
import 'package:liftapp2/data/repository/notifications/authrepository.dart';
import '../../data/models/lift_model.dart';
import '../../data/repository/lift_repository/lift_repository.dart';

class ActiveLiftsController extends GetxController {
  static ActiveLiftsController get instance => Get.find();

  final lifts = <LiftModel>[].obs;
  final isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    fetchUserLifts();
  }

  Future<void> fetchUserLifts({bool fetchLatest = false}) async {
    try {
      if (lifts.isNotEmpty && !fetchLatest) return;

      isLoading.value = true;

      final userId = AuthenticationRepository.instance.getUserID;
      final fetchedLifts = await LiftRepository.instance.getUserLifts(userId);

      lifts.assignAll(fetchedLifts);
      print(lifts);
    } catch (e) {
      print('Error fetching lifts: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addLift(LiftModel lift) async {
    try {
      await LiftRepository.instance.createLift(lift);
      lifts.add(lift); // update in-memory cache
    } catch (e) {
      print('Error creating lift: $e');
      rethrow;
    }
  }

  /// Optional: clear cache
  void clearCache() {
    lifts.clear();
  }
}
