import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../core/services/database_service.dart';
import '../../data/models/transaction_model.dart';
import '../dashboard/dashboard_controller.dart';

class TransactionHistoryController extends GetxController {
  final Isar _isar = Get.find<DatabaseService>().isar;

  var allTransactions = <TransactionModel>[].obs;
  var filteredTransactions = <TransactionModel>[].obs;
  var currentFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  // ডেটাবেস থেকে সব ট্রানজ্যাকশন লেটেস্ট ডেট অনুযায়ী ফেচ করা
  Future<void> loadTransactions() async {
    final txns = await _isar.transactionModels
        .where()
        .sortByDateDesc()
        .findAll();
    allTransactions.value = txns;
    applyFilter(currentFilter.value);
  }

  // ফিল্টার লজিক (All / Income / Expense)
  void applyFilter(String filter) {
    currentFilter.value = filter;
    if (filter == 'All') {
      filteredTransactions.value = allTransactions;
    } else {
      filteredTransactions.value = allTransactions
          .where((t) => t.type.toLowerCase() == filter.toLowerCase())
          .toList();
    }
  }

  // ট্রানজ্যাকশন ডিলিট করা এবং ড্যাশবোর্ড সিঙ্ক করা
  Future<void> deleteTransaction(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.transactionModels.delete(id);
    });

    await loadTransactions();
    Get.find<DashboardController>()
        .loadDashboardData(); // মেইন ব্যালেন্স রিফ্রেশ
    Get.back(); // ডায়ালগ ক্লোজ

    Get.snackbar(
      'Deleted!',
      'ট্রানজ্যাকশন রিমুভ করা হয়েছে।',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
