import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../core/services/database_service.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/income_source_model.dart';
import '../dashboard/dashboard_controller.dart';

class IncomeController extends GetxController {
  final TransactionRepository _repository = Get.find<TransactionRepository>();
  final Isar _isar = Get.find<DatabaseService>().isar;

  // Observables
  var selectedSource = ''.obs;
  var selectedWallet = 'bKash'.obs;
  var sources = <IncomeSourceModel>[].obs;

  final amountController = TextEditingController();
  final noteController = TextEditingController(); // নোটের জন্য

  @override
  void onInit() {
    super.onInit();
    loadSources();
  }

  // ডেটাবেস থেকে সোর্স লোড
  Future<void> loadSources() async {
    final loadedSources = await _isar.incomeSourceModels.where().findAll();
    sources.value = loadedSources;
    if (loadedSources.isNotEmpty) {
      selectedSource.value = loadedSources.first.name;
    }
  }

  void changeSource(String sourceName) {
    selectedSource.value = sourceName;
  }

  // নতুন সোর্স অ্যাড
  Future<void> addNewSource(String name) async {
    if (name.isEmpty) return;

    final newSource = IncomeSourceModel()..name = name;
    await _isar.writeTxn(() async {
      await _isar.incomeSourceModels.put(newSource);
    });

    await loadSources();
    Get.back();
  }

  // সোর্স ডিলিট
  Future<void> deleteSource(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.incomeSourceModels.delete(id);
    });
    await loadSources();
    Get.back();
  }

  // ইনকাম সেভ লজিক
  Future<void> saveIncome() async {
    if (amountController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Amount বসাও আগে!',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    double amount = double.parse(amountController.text);

    final txn = TransactionModel()
      ..type = 'income'
      ..amount = amount
      ..category = selectedSource.value
      ..note = noteController.text.isEmpty
          ? null
          : noteController
                .text // নোট সেভ হচ্ছে
      ..date = DateTime.now();

    await _repository.addTransaction(txn, selectedWallet.value);

    Get.find<DashboardController>().loadDashboardData();

    Get.back();
    Get.snackbar(
      'Cash In! 🤑',
      '৳$amount added to ${selectedWallet.value}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E1E1E),
      colorText: const Color(0xFF39FF14),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
