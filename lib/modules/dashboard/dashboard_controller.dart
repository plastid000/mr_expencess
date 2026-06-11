import 'package:get/get.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction_model.dart';

class DashboardController extends GetxController {
  final TransactionRepository _repository = Get.put(TransactionRepository());

  // Bottom Nav Index
  var tabIndex = 0.obs;

  // Financial Stats
  var currentBalance = 0.0.obs;
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;

  // Recent Transactions
  var recentTransactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  // ডেটাবেস থেকে ডেটা ফেচ করে হিসাব করা
  Future<void> loadDashboardData() async {
    final transactions = await _repository.getAllTransactions();
    recentTransactions.value = transactions
        .take(5)
        .toList(); // লাস্ট ৫টা ট্রানজ্যাকশন

    double income = 0;
    double expense = 0;

    for (var txn in transactions) {
      if (txn.type == 'income') income += txn.amount;
      if (txn.type == 'expense') expense += txn.amount;
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    currentBalance.value =
        income - expense; // আপাতত বেসিক হিসাব, পরে হাওলাত অ্যাড হবে
  }
}
