import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mr_expense/core/services/security_service.dart';
import 'core/theme/dark_theme.dart';
import 'core/services/database_service.dart';
import 'routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/update_service.dart';

// এই দুইটা ভিউ ইমপোর্ট করতে হবে ডাইনামিক রাউটিংয়ের জন্য
import 'modules/security/lock_screen_view.dart';
import 'modules/dashboard/dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ফায়ারবেস ইনিশিয়ালাইজেশন
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // সার্ভিসগুলো মেমোরিতে লোড করা
  await Get.putAsync(() => DatabaseService().init());
  await Get.putAsync(() => SecurityService().init());

  // অটো আপডেট সার্ভিস স্টার্ট (অ্যাপ ওপেন হওয়ার সাথে সাথেই চেক করবে)
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
      getPages: AppPages.routes, // GetX-এর সব রাউট এখান থেকে কন্ট্রোল হবে
      // ডাইনামিক হোম স্ক্রিন: পিন অন থাকলে লক স্ক্রিন, নইলে ডাইরেক্ট ড্যাশবোর্ড
      home: Obx(() {
        final security = Get.find<SecurityService>();
        if (security.isPinEnabled.value) {
          return const LockScreenView();
        } else {
          return const DashboardView();
        }
      }),
    );
  }
}
