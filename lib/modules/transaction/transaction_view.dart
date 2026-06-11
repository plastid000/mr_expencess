import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'transaction_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/transaction_model.dart';

class TransactionHistoryView extends StatelessWidget {
  const TransactionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionHistoryController());

    // ড্যাশবোর্ডে যখনই এই পেজে আসবে, ডেটা রিফ্রেশ হবে
    controller.loadTransactions();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'History',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Smart Filter Bar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(
                () => Row(
                  children: [
                    _buildFilterTab('All', controller),
                    _buildFilterTab('Income', controller),
                    _buildFilterTab('Expense', controller),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Transactions List
            Expanded(
              child: Obx(() {
                if (controller.filteredTransactions.isEmpty) {
                  return const Center(
                    child: Text(
                      'কোনো রেকর্ড পাওয়া যায়নি।',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: controller.filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final txn = controller.filteredTransactions[index];
                    return _buildTransactionCard(txn, controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ফিল্টার বাটন ডিজাইন
  Widget _buildFilterTab(
    String title,
    TransactionHistoryController controller,
  ) {
    final isSelected = controller.currentFilter.value == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.applyFilter(title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.background : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: AppColors.neonGreen.withOpacity(0.3))
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.neonGreen : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ট্রানজ্যাকশন কার্ড ডিজাইন
  Widget _buildTransactionCard(
    TransactionModel txn,
    TransactionHistoryController controller,
  ) {
    final isExpense = txn.type == 'expense';
    final color = isExpense ? AppColors.expenseRed : AppColors.neonGreen;

    // সিম্পল ডেট ফরম্যাট
    final dateStr = '${txn.date.day}/${txn.date.month}/${txn.date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(
                  isExpense
                      ? Icons.shopping_bag_outlined
                      : Icons.account_balance_wallet_outlined,
                  color: color,
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${txn.note != null && txn.note!.isNotEmpty ? txn.note! + " • " : ""}$dateStr',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '${isExpense ? '-' : '+'} ৳${txn.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              // Delete Button
              GestureDetector(
                onTap: () => _showDeleteConfirmDialog(txn, controller),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ডিলিট কনফার্মেশন ডায়ালগ
  void _showDeleteConfirmDialog(
    TransactionModel txn,
    TransactionHistoryController controller,
  ) {
    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      title: 'Delete Record?',
      titleStyle: const TextStyle(
        color: AppColors.expenseRed,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      middleText:
          'এই রেকর্ডটি ডিলিট করলে তোমার মেইন ব্যালেন্স অ্যাডজাস্ট হয়ে যাবে।',
      middleTextStyle: const TextStyle(color: Colors.white70),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.expenseRed),
        onPressed: () => controller.deleteTransaction(txn.id),
        child: const Text(
          'Delete',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}
