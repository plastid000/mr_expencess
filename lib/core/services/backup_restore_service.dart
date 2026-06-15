import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'database_service.dart';
import '../constants/app_colors.dart';

class BackupRestoreService extends GetxService {
  // 🔥 ব্যাকআপ লজিক (Custom Folder Selection)
  Future<void> backupData() async {
    if (!await _requestPermission()) return;

    try {
      final isar = Get.find<DatabaseService>().isar;

      // 🔥 ইউজারকে ফোল্ডার সিলেক্ট করার অপশন দেওয়া হলো
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Backup Folder',
      );

      // ইউজার যদি ফোল্ডার সিলেক্ট না করে ব্যাক করে দেয়
      if (selectedDirectory == null) {
        return;
      }

      // .bak এক্সটেনশন ইউজ করা হলো যাতে ফাইল হিডেন না থাকে
      final fileName =
          'MRExpense_Backup_${DateTime.now().millisecondsSinceEpoch}.bak';
      final path = '$selectedDirectory/$fileName';

      await isar.copyToFile(path);

      Get.snackbar(
        'Backup Successful! 📦',
        'File saved in:\n$path',
        backgroundColor: AppColors.neonGreen,
        colorText: Colors.black,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Backup failed: $e',
        backgroundColor: AppColors.expenseRed,
        colorText: Colors.white,
      );
    }
  }

  // 🔥 রিস্টোর লজিক
  Future<void> restoreData() async {
    if (!await _requestPermission()) return;

    try {
      // 🔥 FileType.any এর বদলে FileType.custom এবং allowedExtensions ইউজ করা হলো
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['bak', 'isar'],
      );

      // .bak অথবা .isar দুইটাই সাপোর্ট করবে
      if (result != null &&
          (result.files.single.path!.endsWith('.bak') ||
              result.files.single.path!.endsWith('.isar'))) {
        final backupFile = File(result.files.single.path!);
        final dir = await getApplicationDocumentsDirectory();

        // রিস্টোর করার সময় অরিজিনাল .isar নামেই সেভ হবে
        final targetPath = '${dir.path}/default.isar';

        final dbService = Get.find<DatabaseService>();
        await dbService.isar.close(); // পুরনো ডাটাবেস ক্লোজ

        await backupFile.copy(targetPath); // নতুন ডাটাবেস রিপ্লেস

        Get.defaultDialog(
          backgroundColor: AppColors.surface,
          title: 'Restore Complete! ♻️',
          titleStyle: const TextStyle(
            color: AppColors.neonGreen,
            fontWeight: FontWeight.bold,
          ),
          middleText:
              'Data restored successfully. The app needs to restart to apply changes.',
          middleTextStyle: const TextStyle(color: Colors.white70),
          barrierDismissible: false,
          confirm: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
            ),
            onPressed: () => exit(0), // অ্যাপ ফোর্স রিস্টার্ট
            child: const Text(
              'Restart App',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else {
        Get.snackbar(
          'Invalid File',
          'Please select a valid .bak backup file.',
          backgroundColor: AppColors.expenseRed,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Restore failed: $e',
        backgroundColor: AppColors.expenseRed,
        colorText: Colors.white,
      );
    }
  }

  // পারমিশন হ্যান্ডলার
  Future<bool> _requestPermission() async {
    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      return true;
    }
    Get.snackbar(
      'Permission Denied',
      'Storage permission is required for backup/restore.',
      backgroundColor: AppColors.expenseRed,
      colorText: Colors.white,
    );
    return false;
  }
}
