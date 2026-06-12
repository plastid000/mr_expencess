import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../core/services/database_service.dart';
import '../../data/models/notification_model.dart';

class NotificationController extends GetxController {
  final Isar _isar = Get.find<DatabaseService>().isar;
  var notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  // পিন করা গুলো উপরে দেখানোর জন্য সর্টিং লজিক
  Future<void> loadNotifications() async {
    final list = await _isar.notificationModels
        .where()
        .sortByIsPinnedDesc() // পিন করাগুলো সবার আগে আসবে
        .thenByTimestampDesc() // তারপর নতুনগুলো
        .findAll();
    notifications.assignAll(list);
  }

  // 🔥 আপডেটেড মেথড: এবার `isPinned` সাপোর্ট করবে
  Future<void> addNotification({
    required String title,
    required String message,
    required String icon,
    bool isPinned = false, // ডিফল্ট false, কিন্তু আপডেট হলে true পাঠাবি
    String actionType = 'none',
  }) async {
    final newNotif = NotificationModel()
      ..title = title
      ..message = message
      ..timestamp = DateTime.now()
      ..isRead = false
      ..icon = icon
      ..isPinned = isPinned
      ..actionType = actionType;

    await _isar.writeTxn(() async {
      await _isar.notificationModels.put(newNotif);
    });

    await loadNotifications();
  }

  Future<void> markAllAsRead() async {
    await _isar.writeTxn(() async {
      for (var notif in notifications) {
        if (!notif.isRead) {
          notif.isRead = true;
          await _isar.notificationModels.put(notif);
        }
      }
    });
    await loadNotifications();
  }

  // NotificationController er vitore ei function ta add koro
  Future<void> removeUpdateNotification() async {
    await _isar.writeTxn(() async {
      // actionType 'update' hoye thakle seta delete kore dibe
      await _isar.notificationModels
          .filter()
          .actionTypeEqualTo('update')
          .deleteAll();
    });
    loadNotifications(); // UI update korar jonno
  }
}
