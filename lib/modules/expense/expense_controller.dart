import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../core/services/database_service.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../dashboard/dashboard_controller.dart';

class ExpenseController extends GetxController {
  final TransactionRepository _repository = Get.put(TransactionRepository());
  final Isar _isar = Get.find<DatabaseService>().isar;

  var selectedCategory = ''.obs;
  var selectedWallet = 'Cash'.obs;
  final noteController = TextEditingController();

  // Dynamic Categories
  var categories = <CategoryModel>[].obs;
  var currentPresets = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final cats = await _isar.categoryModels.where().findAll();
    categories.value = cats;
    if (cats.isNotEmpty) {
      selectedCategory.value = cats.first.name;
      currentPresets.value = cats.first.presets;
    }
  }

  void changeCategory(CategoryModel cat) {
    selectedCategory.value = cat.name;
    currentPresets.value = cat.presets;
  }

  // নতুন ক্যাটাগরি অ্যাড করা
  Future<void> addNewCategory(String name, String presetsString) async {
    if (name.isEmpty) return;

    // "20, 30, 50" স্ট্রিংটাকে লিস্টে কনভার্ট করা
    List<int> parsedPresets = presetsString
        .split(',')
        .map((e) => int.tryParse(e.trim()) ?? 0)
        .where((e) => e > 0)
        .toList();

    if (parsedPresets.isEmpty) parsedPresets = [10, 50, 100]; // Fallback

    final newCat = CategoryModel()
      ..name = name
      ..presets = parsedPresets;

    await _isar.writeTxn(() async {
      await _isar.categoryModels.put(newCat);
    });

    await loadCategories();
    Get.back(); // ডায়ালগ ক্লোজ
  }

  // ক্যাটাগরি ডিলিট করা
  Future<void> deleteCategory(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.categoryModels.delete(id);
    });
    await loadCategories();
    Get.back();
  }

  Future<void> savePresetExpense(int amount) async {
    final txn = TransactionModel()
      ..type = 'expense'
      ..amount = amount.toDouble()
      ..category = selectedCategory.value
      ..note = noteController.text.isEmpty ? null : noteController.text
      ..date = DateTime.now();

    await _repository.addTransaction(txn, selectedWallet.value);
    Get.find<DashboardController>().loadDashboardData();
    Get.back();

    Get.snackbar(
      'Saved!',
      '৳$amount deducted from ${selectedWallet.value}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E1E1E),
      colorText: const Color(0xFF39FF14),
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
