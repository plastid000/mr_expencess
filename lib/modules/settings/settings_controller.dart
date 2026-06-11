import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../core/services/database_service.dart';

class SettingsController extends GetxController {
  final Isar _isar = Get.find<DatabaseService>().isar;

  // সব ডেটা রিসেট করার ফাংশন
  Future<void> clearAllData() async {
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
    Get.snackbar('Success', 'সব ডেটা মুছে ফেলা হয়েছে।');
  }
}
