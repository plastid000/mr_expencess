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

class UpdateService extends GetxService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  var downloadProgress = 0.0.obs;
  var isDownloading = false.obs;

  Future<UpdateService> init() async {
    // UI বিল্ড হওয়ার জন্য সামান্য ডিলে দিয়ে চেক করা শুরু হচ্ছে
    Future.delayed(const Duration(seconds: 2), () {
      _checkForUpdate();
    });
    return this;
  }

  Future<void> _checkForUpdate() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 0),
        ),
      );
      await _remoteConfig.fetchAndActivate();

      String remoteVersion = _remoteConfig.getString('latest_version');
      String apkUrl = _remoteConfig.getString('apk_url').isNotEmpty
          ? _remoteConfig.getString('apk_url')
          : 'https://google.com';
      bool forceUpdate = _remoteConfig.getBool('force_update');

      debugPrint('Firebase Remote Version: $remoteVersion');
      debugPrint('Firebase APK URL: $apkUrl');

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      debugPrint('Current App Version: ${packageInfo.version}');

      if (remoteVersion.isNotEmpty &&
          remoteVersion.trim() != packageInfo.version.trim()) {
        debugPrint('Update Available! Showing dialog...');
        _showUpdateDialog(remoteVersion, apkUrl, forceUpdate);
      } else {
        debugPrint('No Update Needed.');
      }
    } catch (e) {
      debugPrint('Update Check Error: $e');
    }
  }

  void _showUpdateDialog(String version, String url, bool forceUpdate) {
    Get.dialog(
      PopScope(
        canPop: !forceUpdate,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'New Update Available! 🚀',
            style: TextStyle(
              color: AppColors.neonGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Version $version is ready.',
                  style: const TextStyle(color: Colors.white70),
                ),
                if (isDownloading.value) ...[
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: downloadProgress.value,
                    color: AppColors.neonGreen,
                  ),
                  Text(
                    '${(downloadProgress.value * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (!isDownloading.value) ...[
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Later'),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                ),
                onPressed: () => _downloadAndInstall(url),
                child: const Text(
                  'Update Now',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ],
        ),
      ),
      barrierDismissible: !forceUpdate,
    );
  }

  Future<void> _downloadAndInstall(String url) async {
    // অ্যান্ড্রয়েড ১৩ বা তার ওপরের ভার্সনের জন্য পারমিশন চেক
    final status = await Permission.storage.request();
    final manageStatus = await Permission.manageExternalStorage.request();

    if (status.isGranted || manageStatus.isGranted) {
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
        Get.back();
      } catch (e) {
        isDownloading.value = false;
        debugPrint('Download/Install Error: $e');
        Get.snackbar(
          'Error',
          'Update failed!',
          backgroundColor: AppColors.expenseRed,
        );
      }
    } else {
      // পারমিশন ডিনায়েড হলে সেটিংসে যাওয়ার অপশন
      Get.snackbar(
        'Permission Required',
        'ডাউনলোডের জন্য স্টোরেজ পারমিশন প্রয়োজন।',
        mainButton: TextButton(
          onPressed: openAppSettings,
          child: const Text('Settings'),
        ),
      );
    }
  }
}
