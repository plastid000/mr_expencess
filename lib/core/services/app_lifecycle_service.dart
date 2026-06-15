import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../routes/app_routes.dart';

class AppLifecycleService extends GetxService with WidgetsBindingObserver {
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 🔥 ফিক্সড: 'user_pin' এর বদলে 'isPinEnabled' দিয়ে চেক করা হচ্ছে
    bool hasPin = box.read('isPinEnabled') == true;

    // অ্যাপ যখন ব্যাকগ্রাউন্ডে যায়
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      // কিবোর্ড আনফোকাস করে দেওয়া হলো
      FocusManager.instance.primaryFocus?.unfocus();

      if (hasPin) box.write('is_locked', true);
    }
    // অ্যাপ যখন আবার ওপেন হয়
    else if (state == AppLifecycleState.resumed) {
      if (box.read('is_locked') == true &&
          Get.currentRoute != Routes.LOCK_SCREEN) {
        // ইঞ্জিন রেডি হওয়ার জন্য ১০০ মিলি-সেকেন্ড সময় দিয়ে তারপর পুশ করা হলো
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.toNamed(Routes.LOCK_SCREEN);
        });
      }
    }
  }
}
