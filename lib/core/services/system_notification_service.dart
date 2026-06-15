import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'update_service.dart';

class SystemNotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<SystemNotificationService> init() async {
    // Android icon setup (Make sure you have an icon named ic_launcher in mipmap)
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    // 🔥 ম্যাজিক ফিক্স: initializationSettings এর বদলে শুধু settings বসানো হলো!
    await _notificationsPlugin.initialize(
      settings: initSettings, // <-- ঠিক এই জায়গাটাই চেঞ্জ হয়েছে
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        if (details.payload == 'update_app') {
          // নোটিফিকেশনে ট্যাপ করলে সরাসরি আপডেট ডায়ালগ ওপেন হবে
          if (Get.isRegistered<UpdateService>()) {
            Get.find<UpdateService>().showUpdateDialogFromPayload();
          }
        }
      },
    );
    return this;
  }

  Future<void> showUpdateNotification(String version, bool isForced) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mr_expense_update',
      'App Updates',
      channelDescription: 'MR Expense OS Updates',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: isForced, // Force update হলে নোটিফিকেশন পিনড থাকবে
      autoCancel: !isForced,
      icon: '@mipmap/ic_launcher',
    );

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id: 0,
      title: 'New Update Available 🚀',
      body: 'Version $version is ready. Tap to install now.',
      notificationDetails: platformDetails,
      payload: 'update_app',
    );
  }

  Future<void> cancelUpdateNotification() async {
    await _notificationsPlugin.cancel(id: 0);
  }
}
