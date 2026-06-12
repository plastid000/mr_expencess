import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mr_expense/modules/notifications/notification_controller.dart';
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
      String apkUrl = _remoteConfig.getString('apk_url');
      bool forceUpdate = _remoteConfig.getBool('force_update');
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final notificationCtrl = Get.find<NotificationController>();

      if (remoteVersion.isNotEmpty &&
          remoteVersion.trim() == packageInfo.version.trim()) {
        await notificationCtrl.removeUpdateNotification();
      } else if (remoteVersion.isNotEmpty &&
          remoteVersion.trim() != packageInfo.version.trim()) {
        bool alreadyExists = notificationCtrl.notifications.any(
          (n) => n.actionType == 'update',
        );
        if (!alreadyExists) {
          await notificationCtrl.addNotification(
            title: 'Update Available! 🚀',
            message: 'Version $remoteVersion is ready. Tap to install.',
            icon: '⚡',
            isPinned: true,
            actionType: 'update',
          );
        }
        // অ্যাপ ওপেন হলেও ডায়ালগ দেখাবে
        showUpdateDialog(remoteVersion, apkUrl, forceUpdate);
      }
    } catch (e) {
      debugPrint('Update Check Error: $e');
    }
  }

  // পাবলিক মেথড
  void showUpdateDialog(String version, String url, bool forceUpdate) {
    Get.defaultDialog(
      title: 'New Update Available',
      titleStyle: const TextStyle(
        color: AppColors.neonGreen,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: AppColors.surface,
      barrierDismissible: !forceUpdate,
      content: Column(
        children: [
          const Icon(Icons.system_update, size: 50, color: AppColors.neonGreen),
          const SizedBox(height: 10),
          Text(
            'Version $version is ready to download.',
            style: const TextStyle(color: Colors.white),
          ),
          Obx(
            () => isDownloading.value
                ? Column(
                    children: [
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: downloadProgress.value,
                        color: AppColors.neonGreen,
                      ),
                    ],
                  )
                : const SizedBox(),
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
                onPressed: () => downloadAndInstall(url),
                child: const Text(
                  'Update Now',
                  style: TextStyle(color: Colors.black),
                ),
              ),
      ),
      cancel: forceUpdate
          ? null
          : TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Later',
                style: TextStyle(color: Colors.white70),
              ),
            ),
    );
  }

  Future<void> downloadAndInstall(String url) async {
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
        Get.snackbar(
          'Error',
          'Update failed!',
          backgroundColor: AppColors.expenseRed,
        );
      }
    }
  }
}
