import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_colors.dart';

class UpdateService extends GetxService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<UpdateService> init() async {
    await checkForUpdate();
    return this;
  }

  Future<void> checkForUpdate() async {
    try {
      // Remote Config সেটআপ (ফাস্ট ফেচিংয়ের জন্য টাইমআউট কমানো হলো)
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(
            minutes: 1,
          ), // প্রোডাকশনে এটা কয়েক ঘণ্টা করে দিও
        ),
      );
      await _remoteConfig.fetchAndActivate();

      // সার্ভার থেকে ডেটা নেওয়া
      String remoteVersion = _remoteConfig.getString('latest_version');
      String apkUrl = _remoteConfig.getString('apk_url');

      // অ্যাপের বর্তমান ভার্সন চেক করা
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // ভার্সন কম্পেয়ার করা
      if (remoteVersion.isNotEmpty &&
          apkUrl.isNotEmpty &&
          _isUpdateAvailable(currentVersion, remoteVersion)) {
        _showUpdateDialog(remoteVersion, apkUrl);
      }
    } catch (e) {
      debugPrint('Update Check Error: $e');
    }
  }

  // ভার্সন কম্পেয়ার লজিক (e.g. 1.0.0 vs 1.0.1)
  bool _isUpdateAvailable(String current, String remote) {
    try {
      List<int> currVals = current.split('.').map(int.parse).toList();
      List<int> remVals = remote.split('.').map(int.parse).toList();
      for (int i = 0; i < 3; i++) {
        if (remVals[i] > currVals[i]) return true;
        if (remVals[i] < currVals[i]) return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void _showUpdateDialog(String version, String url) {
    Get.defaultDialog(
      barrierDismissible: false, // ইউজার যেন ইগনোর করতে না পারে (Force Update)
      backgroundColor: AppColors.surface,
      title: 'New Update Available! 🚀',
      titleStyle: const TextStyle(
        color: AppColors.neonGreen,
        fontWeight: FontWeight.bold,
      ),
      content: Text(
        'Version $version is ready to install.',
        style: const TextStyle(color: Colors.white70),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen),
        onPressed: () {
          Get.back();
          _downloadAndInstall(url);
        },
        child: const Text(
          'Update Now',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Later', style: TextStyle(color: Colors.white54)),
      ),
    );
  }

  Future<void> _downloadAndInstall(String url) async {
    // স্টোরেজ পারমিশন চেক
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    Get.snackbar(
      'Downloading...',
      'আপডেট ব্যাকগ্রাউন্ডে ডাউনলোড হচ্ছে।',
      backgroundColor: AppColors.surface,
      colorText: AppColors.neonGreen,
      snackPosition: SnackPosition.BOTTOM,
    );

    try {
      OtaUpdate()
          .execute(url, destinationFilename: 'mrexpense_update.apk')
          .listen((OtaEvent event) {
            if (event.status == OtaStatus.INSTALLING) {
              Get.snackbar(
                'Success',
                'ইন্সটলেশন শুরু হচ্ছে...',
                backgroundColor: AppColors.surface,
                colorText: AppColors.neonGreen,
              );
            } else if (event.status == OtaStatus.DOWNLOADING) {
              // চাইলে এখানে প্রগ্রেস বার দেখানো যায়
            }
          });
    } catch (e) {
      Get.snackbar(
        'Error',
        'ডাউনলোড ফেইল হয়েছে!',
        backgroundColor: AppColors.expenseRed,
        colorText: Colors.white,
      );
    }
  }
}
