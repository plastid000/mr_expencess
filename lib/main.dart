import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mr_expense/core/services/security_service.dart';
import 'package:mr_expense/core/services/app_lifecycle_service.dart';
import 'core/theme/dark_theme.dart';
import 'core/services/database_service.dart';
import 'routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/update_service.dart';
// import 'core/services/system_notification_service.dart'; // 🔥 যদি সার্ভিসটা বানিয়ে থাকিস, এটা আনকমেন্ট করিস

// 🔥 ফোল্ডারের নতুন পাথ দেওয়া হলো
import 'modules/lock_screen/lock_screen_view.dart';
import 'modules/dashboard/dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Get.putAsync(() => DatabaseService().init());
  await Get.putAsync(() => SecurityService().init());
  // await Get.putAsync(() => SystemNotificationService().init()); // 🔥 সিস্টেম নোটিফিকেশন সার্ভিস

  Get.put(AppLifecycleService());
  Get.putAsync(() => UpdateService().init());

  runApp(const MrExpenseApp());
}

class MrExpenseApp extends StatelessWidget {
  const MrExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MR Expense OS',
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes,
      home: Obx(() {
        final security = Get.find<SecurityService>();
        final box = GetStorage();
        bool isLocked = box.read('is_locked') ?? true;

        if (security.isPinEnabled.value && isLocked) {
          return const LockScreenView();
        } else {
          return const DashboardView();
        }
      }),
    );
  }
}
