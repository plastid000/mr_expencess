import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_colors.dart';
import 'system_notification_service.dart'; // 🔥 সিস্টেম নোটিফিকেশন

class UpdateService extends GetxService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  var downloadProgress = 0.0.obs;
  var isDownloading = false.obs;

  String? _latestVersion;
  String? _apkUrl;
  bool _forceUpdate = false;
  String? _currentVersion;

  Future<UpdateService> init() async {
    // 🔥 অটোমেটিক চেক বাদ। এখন শুধু আনলক হলেই চেক হবে!
    return this;
  }

  // এই মেথডটা আনলক করার পর কল হবে
  Future<void> checkForUpdate() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 0),
        ),
      );
      await _remoteConfig.fetchAndActivate();

      _latestVersion = _remoteConfig.getString('latest_version');
      _apkUrl = _remoteConfig.getString('apk_url');
      _forceUpdate = _remoteConfig.getBool('force_update');

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = packageInfo.version;

      final sysNotification = Get.find<SystemNotificationService>();

      if (_latestVersion != null &&
          _latestVersion!.isNotEmpty &&
          _latestVersion!.trim() != _currentVersion!.trim()) {
        // ১. সিস্টেম নোটিফিকেশন পুশ করা
        sysNotification.showUpdateNotification(_latestVersion!, _forceUpdate);
        // ২. ডিরেক্ট ডায়ালগ শো করা
        showUpdateDialog();
      } else {
        // অলরেডি লেটেস্ট ভার্সনে থাকলে নোটিফিকেশন ক্লিয়ার করে দিবে
        sysNotification.cancelUpdateNotification();
      }
    } catch (e) {
      debugPrint(
        'Update Check Error: $e',
      ); // ইন্টারনেট না থাকলে সাইলেন্টলি স্কিপ করবে
    }
  }

  void showUpdateDialogFromPayload() {
    if (_latestVersion != null)
      showUpdateDialog();
    else
      checkForUpdate();
  }

  void showUpdateDialog() {
    if (Get.isDialogOpen == true) return;

    Get.defaultDialog(
      title: 'Update Available 🚀',
      titleStyle: const TextStyle(
        color: AppColors.neonGreen,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: AppColors.surface,
      barrierDismissible:
          !_forceUpdate, // ফোর্স আপডেট হলে বাইরে ক্লিক করে কাটতে পারবে না
      content: Column(
        children: [
          const Icon(Icons.system_update, size: 50, color: AppColors.neonGreen),
          const SizedBox(height: 15),
          // 🔥 রিকোয়ারমেন্ট অনুযায়ী ২টা ভার্সনই দেখানো হচ্ছে
          Text(
            'Current Version: $_currentVersion',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'New Version: $_latestVersion',
            style: const TextStyle(
              color: AppColors.neonGreen,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 15),

          Obx(
            () => isDownloading.value
                ? Column(
                    children: [
                      Text(
                        '${(downloadProgress.value * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                        value: downloadProgress.value,
                        color: AppColors.neonGreen,
                        backgroundColor: Colors.white24,
                      ),
                    ],
                  )
                : const Text(
                    'Do you want to update now?',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
          ),
        ],
      ),
      confirm: Obx(
        () => isDownloading.value
            ? const SizedBox()
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                ),
                onPressed: () => downloadAndInstall(_apkUrl!),
                child: const Text(
                  'Update Now',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
      cancel: _forceUpdate
          ? null
          : Obx(
              () => isDownloading.value
                  ? const SizedBox()
                  : TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Later',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
            ),
    );
  }

  Future<void> downloadAndInstall(String url) async {
    final status = await Permission.storage.request();
    final installStatus = await Permission.requestInstallPackages
        .request(); // Android 11+ এর জন্য জরুরি

    if (status.isGranted || installStatus.isGranted) {
      isDownloading.value = true;
      try {
        Directory? dir =
            await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
        String path = "${dir.path}/mrexpense_update.apk";
        await Dio().download(
          url,
          path,
          onReceiveProgress: (rec, total) {
            if (total != -1) downloadProgress.value = rec / total;
          },
        );
        isDownloading.value = false;
        await OpenFilex.open(path);
        Get.back(); // ডাউনলোড শেষে ডায়ালগ ক্লোজ
      } catch (e) {
        isDownloading.value = false;
        Get.snackbar(
          'Error',
          'Update failed!',
          backgroundColor: AppColors.expenseRed,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Permission Denied',
        'Storage permission required for update.',
        backgroundColor: AppColors.expenseRed,
        colorText: Colors.white,
      );
    }
  }
}
