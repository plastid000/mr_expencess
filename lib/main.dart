import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // 🔥 GetStorage ইমপোর্ট করা হলো
import 'package:mr_expense/core/services/security_service.dart';
import 'package:mr_expense/core/services/app_lifecycle_service.dart'; // 🔥 Lifecycle সার্ভিস ইমপোর্ট
import 'core/theme/dark_theme.dart';
import 'core/services/database_service.dart';
import 'routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/update_service.dart';

import 'modules/security/lock_screen_view.dart';
import 'modules/dashboard/dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 GetStorage ইনিশিয়ালাইজেশন (এটা না দিলে পিন সেভ/রিড হবে না)
  await GetStorage.init();

  // ফায়ারবেস ইনিশিয়ালাইজেশন
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // সার্ভিসগুলো মেমোরিতে লোড করা
  await Get.putAsync(() => DatabaseService().init());
  await Get.putAsync(() => SecurityService().init());

  // 🔥 অ্যাপ লাইফসাইকেল সার্ভিস গ্লোবালি স্টার্ট করা হলো
  Get.put(AppLifecycleService());

  // অটো আপডেট সার্ভিস স্টার্ট
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
      // ডাইনামিক হোম স্ক্রিন: পিন অন থাকলে এবং আনলক না হলে লক স্ক্রিন
      home: Obx(() {
        final security = Get.find<SecurityService>();
        final box = GetStorage();
        bool isLocked = box.read('is_locked') ?? true; // অটো-লক চেক

        if (security.isPinEnabled.value && isLocked) {
          return const LockScreenView();
        } else {
          return const DashboardView();
        }
      }),
    );
  }
}
