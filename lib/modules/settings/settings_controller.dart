import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../core/services/database_service.dart';
import '../../data/models/user_settings_model.dart'; // ⚠️ এই মডেল ফাইলটা কিন্তু থাকা লাগবে

class SettingsController extends GetxController {
  final Isar _isar = Get.find<DatabaseService>().isar;

  // Observables for UI binding
  var userName = 'Rahat'.obs;
  var wallets = <String>[].obs;
  var expenseCategories = <String>[].obs;

  // ফিউচার-প্রুফিংয়ের জন্য প্রোফাইল পিকচার ও ইমেইল
  var userEmail = 'local@mrtechbd.net'.obs;
  var userPhotoUrl = ''.obs;

  int? _currentLocalId;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  // ১. ডেটাবেস থেকে সেটিংস লোড (অফলাইন/লোকাল)
  Future<void> loadSettings() async {
    var settings = await _isar.userSettingsModels.where().findFirst();

    // প্রথমবার অ্যাপ ওপেন হলে ডিফল্ট ডেটা সেটআপ হবে
    if (settings == null) {
      settings = UserSettingsModel()
        ..firebaseUid = 'local_user_only'
        ..email = 'local@mrtechbd.net'
        ..photoUrl = ''
        ..userName = 'Rahat'
        ..wallets = ['Cash', 'bKash', 'Nagad', 'Bank']
        ..expenseCategories = ['Food', 'Transport', 'Bills']
        ..isSynced = false;

      await _isar.writeTxn(() async {
        _currentLocalId = await _isar.userSettingsModels.put(settings!);
      });
    } else {
      _currentLocalId = settings.id;
    }

    // UI-তে ডেটা পুশ
    userName.value = settings.userName;
    userEmail.value = settings.email ?? 'local@mrtechbd.net';
    userPhotoUrl.value = settings.photoUrl ?? '';
    wallets.assignAll(settings.wallets);
    expenseCategories.assignAll(settings.expenseCategories);
  }

  // ইউজার নেম আপডেট করা
  Future<void> updateName(String newName) async {
    if (newName.isEmpty) return;
    userName.value = newName;
    await _updateDatabase();
  }

  // ডায়নামিক ওয়ালেট অ্যাড করা
  Future<void> addWallet(String walletName) async {
    if (walletName.isEmpty || wallets.contains(walletName)) return;
    wallets.add(walletName);
    await _updateDatabase();
  }

  // ওয়ালেট রিমুভ করা
  Future<void> removeWallet(String walletName) async {
    if (wallets.length <= 1) {
      Get.snackbar(
        'Error',
        'অন্তত একটি ওয়ালেট থাকতে হবে!',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    wallets.remove(walletName);
    await _updateDatabase();
  }

  // কাস্টম এক্সপেন্স ক্যাটাগরি অ্যাড করা
  Future<void> addCategory(String categoryName) async {
    if (categoryName.isEmpty || expenseCategories.contains(categoryName))
      return;
    expenseCategories.add(categoryName);
    await _updateDatabase();
  }

  // ক্যাটাগরি রিমুভ করা
  Future<void> removeCategory(String categoryName) async {
    if (expenseCategories.length <= 1) {
      Get.snackbar(
        'Error',
        'অন্তত একটি ক্যাটাগরি রাখুন!',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    expenseCategories.remove(categoryName);
    await _updateDatabase();
  }

  // লোকাল ডেটাবেস রাইট মেথড
  Future<void> _updateDatabase() async {
    if (_currentLocalId == null) return;

    final existingSettings = await _isar.userSettingsModels.get(
      _currentLocalId!,
    );
    if (existingSettings != null) {
      existingSettings.userName = userName.value;
      existingSettings.wallets = wallets.toList();
      existingSettings.expenseCategories = expenseCategories.toList();
      existingSettings.isSynced = false;

      await _isar.writeTxn(() async {
        await _isar.userSettingsModels.put(existingSettings);
      });
    }
  }

  // সব ডেটা ক্লিয়ার/রিসেট
  Future<void> clearAllData() async {
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
    await loadSettings();
    Get.snackbar(
      'Success',
      'সব লোকাল ডেটা রিসেট করা হয়েছে।',
      backgroundColor: Colors.orangeAccent,
      colorText: Colors.black,
    );
  }
}
