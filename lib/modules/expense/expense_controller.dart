import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:mr_expense/modules/notifications/notification_controller.dart';
import '../../core/services/database_service.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../dashboard/dashboard_controller.dart';
// ⚠️ তোমার ফোল্ডার স্ট্রাকচার অনুযায়ী এই ইমপোর্ট পাথটা ঠিক করে নিও
import '../transaction/transaction_controller.dart';

class ExpenseController extends GetxController {
  final TransactionRepository _repository = Get.put(TransactionRepository()); //
  final Isar _isar = Get.find<DatabaseService>().isar; //

  var selectedCategory = ''.obs; //
  var selectedWallet = 'Cash'.obs; //
  final noteController = TextEditingController(); //
  final customAmountController = TextEditingController(); // কাস্টম ইনপুটের জন্য

  // Dynamic Categories
  var categories = <CategoryModel>[].obs; //
  var currentPresets = <int>[].obs; //

  @override
  void onInit() {
    super.onInit();
    loadCategories(); //
  }

  Future<void> loadCategories() async {
    final cats = await _isar.categoryModels.where().findAll(); //
    categories.value = cats; //
    if (cats.isNotEmpty) {
      //
      selectedCategory.value = cats.first.name; //
      currentPresets.value = cats.first.presets; //
    }
  }

  void changeCategory(CategoryModel cat) {
    selectedCategory.value = cat.name; //
    currentPresets.value = cat.presets; //
  }

  // নতুন ক্যাটাগরি অ্যাড করা
  Future<void> addNewCategory(String name, String presetsString) async {
    if (name.isEmpty) return; //

    List<int> parsedPresets =
        presetsString //
            .split(',') //
            .map((e) => int.tryParse(e.trim()) ?? 0) //
            .where((e) => e > 0) //
            .toList(); //

    if (parsedPresets.isEmpty) parsedPresets = [10, 50, 100]; // Fallback

    final newCat =
        CategoryModel() //
          ..name =
              name //
          ..presets = parsedPresets; //

    await _isar.writeTxn(() async {
      //
      await _isar.categoryModels.put(newCat); //
    });

    await loadCategories(); //
    Get.back(); // ডায়ালগ ক্লোজ
  }

  // ক্যাটাগরি ডিলিট করা
  Future<void> deleteCategory(Id id) async {
    await _isar.writeTxn(() async {
      //
      await _isar.categoryModels.delete(id); //
    });
    await loadCategories(); //
    Get.back(); //
  }

  // Modified: Custom + Preset Amount Save Logic
  Future<void> saveExpense(double amount) async {
    if (amount <= 0) {
      Get.snackbar(
        'Error',
        'সঠিক অ্যামাউন্ট দিন!',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final txn =
        TransactionModel() //
          ..type =
              'expense' //
          ..amount =
              amount //
          ..category = selectedCategory
              .value //
          ..note = noteController.text.isEmpty
              ? null
              : noteController
                    .text //
          ..walletName = selectedWallet.value
          ..date = DateTime.now(); //

    await _repository.addTransaction(txn, selectedWallet.value); //

    // 🔥 স্টেট অটো-আপডেট (যাতে অ্যাপ থেকে বের হতে না হয়)
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadDashboardData(); //
    }
    if (Get.isRegistered<TransactionHistoryController>()) {
      Get.find<TransactionHistoryController>().loadTransactions();
    }

    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().addNotification(
        title: 'Expense Added! 📉',
        message:
            '৳${amount.toStringAsFixed(0)} spent on ${selectedCategory.value}',
        icon: '💸',
      );
    }

    Get.back(); //

    Get.snackbar(
      'Saved!', //
      '৳${amount.toStringAsFixed(0)} deducted from ${selectedWallet.value}', //
      snackPosition: SnackPosition.TOP, //
      backgroundColor: const Color(0xFF1E1E1E), //
      colorText: const Color(0xFF39FF14), //
      duration: const Duration(seconds: 1), //
    );
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().addNotification(
        title: 'Expense Added!',
        message: '৳${amount.toStringAsFixed(0)} deducted for $selectedCategory',
        icon: '📉',
      );
    }
  }

  // Custom Field Submit Handler
  void submitCustomAmount() {
    final amount = double.tryParse(customAmountController.text) ?? 0.0;
    saveExpense(amount);
  }

  @override
  void onClose() {
    noteController.dispose(); //
    customAmountController.dispose();
    super.onClose(); //
  }
}
