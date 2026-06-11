import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../core/services/database_service.dart';
import '../../data/models/transaction_model.dart';

class AnalyticsController extends GetxController {
  final Isar _isar = Get.find<DatabaseService>().isar;

  // Overview Data
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;

  // Charts Data
  var categoryData = <Map<String, dynamic>>[].obs;
  var barData = <double>[0.0, 0.0].obs; // [Last Month, This Month]

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  // সব ক্যালকুলেশন একবারে আপডেট করার ফাংশন
  Future<void> refreshData() async {
    await calculateStats();
    await calculateMonthlyComparison();
  }

  Future<void> calculateStats() async {
    final transactions = await _isar.transactionModels.where().findAll();

    double income = 0;
    double expense = 0;
    Map<String, double> catMap = {};

    for (var txn in transactions) {
      if (txn.type == 'income') {
        income += txn.amount;
      } else {
        expense += txn.amount;
        // Category wise sum
        catMap[txn.category] = (catMap[txn.category] ?? 0) + txn.amount;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;

    // Convert to list for Pie Chart
    categoryData.value = catMap.entries
        .map((e) => {'name': e.key, 'value': e.value})
        .toList();
  }

  Future<void> calculateMonthlyComparison() async {
    final now = DateTime.now();
    final transactions = await _isar.transactionModels.where().findAll();

    double lastMonthExp = 0;
    double thisMonthExp = 0;

    for (var txn in transactions.where((t) => t.type == 'expense')) {
      // এই মাসের খরচ
      if (txn.date.month == now.month && txn.date.year == now.year) {
        thisMonthExp += txn.amount;
      }
      // গত মাসের খরচ (Month-1 handle)
      else if (txn.date.month == (now.month == 1 ? 12 : now.month - 1) &&
          txn.date.year == (now.month == 1 ? now.year - 1 : now.year)) {
        lastMonthExp += txn.amount;
      }
    }
    barData.value = [lastMonthExp, thisMonthExp];
  }
}
