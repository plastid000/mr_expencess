import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mr_expense/core/services/app_lifecycle_service.dart';
import 'package:mr_expense/modules/analytics/analytics_view.dart';
import 'package:mr_expense/modules/notifications/notification_controller.dart';
import 'package:mr_expense/modules/settings/settings_view.dart';
import 'package:mr_expense/modules/transaction/transaction_view.dart';
import 'dashboard_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart'; // রাউটিংয়ের জন্য
import '../loans/loans_view.dart'; // Loans UI এর জন্য
import '../loans/loan_controller.dart'; // Loan Dialog এর জন্য
import '../settings/settings_controller.dart';

// 🔥 GetView এর বদলে StatelessWidget দেওয়া হলো
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    Get.put(SettingsController());
    Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: [
            _buildHomeTab(
              controller,
            ), // হোম কন্টেন্ট আলাদা মেথডে নিয়ে গেছি ক্লিন রাখার জন্য
            TransactionHistoryView(),
            LoansView(),
            AnalyticsView(),
            SettingsView(),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          shape: const CircleBorder(
            side: BorderSide(color: AppColors.neonGreen, width: 2),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.neonGreen,
          elevation: 0,
          highlightElevation: 0,
          onPressed: () => _showQuickActionBottomSheet(),
          child: const Icon(Icons.add, size: 32),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

      // 🔥 ব্যালেন্সড বটম নেভিগেশন বার
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.neonGreen,
          unselectedItemColor: AppColors.textSecondary,
          currentIndex: controller.tabIndex.value,
          onTap: (index) => controller.changeTabIndex(index),

          selectedFontSize: 11,
          unselectedFontSize: 11,
          iconSize: 24,
          showUnselectedLabels: true,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: "Txn",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: "Loan",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: "Stats",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}

Widget _navItem({
  required IconData icon,
  required String label,
  required int index,
  required DashboardController controller,
}) {
  final isSelected = controller.tabIndex.value == index;

  return GestureDetector(
    onTap: () => controller.changeTabIndex(index),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 22,
          color: isSelected ? AppColors.expenseRed : AppColors.textSecondary,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? AppColors.neonGreen : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

// হোম ট্যাবের রিয়েল-টাইম ব্যালেন্স UI
Widget _buildHomeTab(DashboardController controller) {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  // 🔥 ১ ও ৪: ডায়নামিক ইউজার নেম বসানো হলো
                  Obx(
                    () => Text(
                      Get.find<SettingsController>().userName.value,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: AppColors.surface,
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.neonGreen,
                  ),
                  onPressed: () {
                    // 🔥 ৬. নোটিফিকেশন বাটন রাউটিং
                    Get.toNamed(Routes.NOTIFICATIONS);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Main Balance Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.surface, AppColors.background],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonGreen.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Balance',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    '৳ ${controller.currentBalance.value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.arrow_downward,
                              color: AppColors.neonGreen,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Income',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            '৳ ${controller.totalIncome.value.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              color: AppColors.expenseRed,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Expense',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            '৳ ${controller.totalExpense.value.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Recent Transactions List
          const Text(
            'Recent Activity',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Obx(() {
              if (controller.recentTransactions.isEmpty) {
                return const Center(
                  child: Text(
                    'No transactions yet.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.recentTransactions.length,
                itemBuilder: (context, index) {
                  final txn = controller.recentTransactions[index];
                  final isExpense = txn.type == 'expense';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isExpense
                          ? AppColors.expenseRed.withOpacity(0.1)
                          : AppColors.neonGreen.withOpacity(0.1),
                      child: Icon(
                        isExpense
                            ? Icons.shopping_bag_outlined
                            : Icons.account_balance_wallet_outlined,
                        color: isExpense
                            ? AppColors.expenseRed
                            : AppColors.neonGreen,
                      ),
                    ),
                    title: Text(
                      txn.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // 🔥 ৩. ডাইনামিক ওয়ালেট নাম ও নোট
                    subtitle: Text(
                      txn.note != null && txn.note!.isNotEmpty
                          ? '${txn.walletName ?? 'Cash'} • ${txn.note}'
                          : txn.walletName ?? 'Cash',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      '${isExpense ? '-' : '+'} ৳${txn.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isExpense
                            ? AppColors.expenseRed
                            : AppColors.neonGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    ),
  );
}

// Quick Action Bottom Sheet
void _showQuickActionBottomSheet() {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                Icons.arrow_upward,
                'Expense',
                AppColors.expenseRed,
                () {
                  Get.back();
                  Get.toNamed(Routes.ADD_EXPENSE);
                },
              ),
              _buildActionButton(
                Icons.arrow_downward,
                'Income',
                AppColors.neonGreen,
                () {
                  Get.back();
                  Get.toNamed(Routes.ADD_INCOME);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                Icons.handshake_outlined,
                'Loan Given',
                Colors.blueAccent,
                () {
                  Get.back();
                  _showAddLoanDialog('I Will Get', AppColors.neonGreen);
                },
              ),
              _buildActionButton(
                Icons.request_quote_outlined,
                'Loan Taken',
                Colors.orangeAccent,
                () {
                  Get.back();
                  _showAddLoanDialog('I Will Pay', AppColors.expenseRed);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

// হাওলাত অ্যাড করার ডায়ালগ বক্স
void _showAddLoanDialog(String type, Color color) {
  final loanController = Get.put(LoanController());
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  Get.defaultDialog(
    backgroundColor: AppColors.surface,
    title: type == 'I Will Get' ? 'কাকে ধার দিলে?' : 'কার থেকে ধার নিলে?',
    titleStyle: TextStyle(
      color: color,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    content: Column(
      children: [
        TextField(
          controller: nameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Name (e.g. Rakib)',
            hintStyle: TextStyle(color: Colors.white30),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Amount (e.g. 500)',
            hintStyle: TextStyle(color: Colors.white30),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: noteCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Note (Optional)',
            hintStyle: TextStyle(color: Colors.white30),
          ),
        ),
      ],
    ),
    confirm: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: () {
        loanController.addLoan(
          name: nameCtrl.text,
          amount: double.tryParse(amountCtrl.text) ?? 0.0,
          type: type,
          note: noteCtrl.text,
        );
      },
      child: const Text(
        'Save Record',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    cancel: TextButton(
      onPressed: () => Get.back(),
      child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
    ),
  );
}

// কাস্টম বাটন উইজেট
Widget _buildActionButton(
  IconData icon,
  String label,
  Color color,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
