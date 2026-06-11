import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'loan_controller.dart';
import '../../core/constants/app_colors.dart';

class LoansView extends StatelessWidget {
  const LoansView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoanController());

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hawlat Ledger',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // I Will Get Section (আমি পাবো)
            const Text(
              'I Will Get (আমি পাবো) 🟢',
              style: TextStyle(
                color: AppColors.neonGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (controller.iWillGetLoans.isEmpty) {
                  return const Center(
                    child: Text(
                      'কেউ তোমার কাছে ধার নেয়নি।',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: controller.iWillGetLoans.length,
                  itemBuilder: (context, index) {
                    final loan = controller.iWillGetLoans[index];
                    return _buildLoanCard(
                      loan,
                      AppColors.neonGreen,
                      controller,
                    );
                  },
                );
              }),
            ),

            const Divider(color: Colors.white24, height: 30),

            // I Will Pay Section (আমি দিবো)
            const Text(
              'I Will Pay (আমি দিবো) 🔴',
              style: TextStyle(
                color: AppColors.expenseRed,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (controller.iWillPayLoans.isEmpty) {
                  return const Center(
                    child: Text(
                      'তুমি কারো কাছে ঋণী নও।',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: controller.iWillPayLoans.length,
                  itemBuilder: (context, index) {
                    final loan = controller.iWillPayLoans[index];
                    return _buildLoanCard(
                      loan,
                      AppColors.expenseRed,
                      controller,
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

  // লোন কার্ড ডিজাইন
  Widget _buildLoanCard(loan, Color color, LoanController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loan.personName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (loan.note != null && loan.note!.isNotEmpty)
                Text(
                  loan.note!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          Row(
            children: [
              Text(
                '৳${loan.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 15),
              GestureDetector(
                onTap: () => _showSettleConfirmDialog(
                  loan,
                  color,
                  controller,
                ), // এখানে কনফার্মেশন ডায়ালগ কল করা হলো
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Settle',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // কনফার্মেশন ডায়ালগ মেথড
  void _showSettleConfirmDialog(loan, Color color, LoanController controller) {
    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      title: 'Settle Account?',
      titleStyle: TextStyle(
        color: color,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      middleText:
          '${loan.personName}-এর ৳${loan.amount.toStringAsFixed(0)} কি ক্লিয়ার হয়ে গেছে?',
      middleTextStyle: const TextStyle(color: Colors.white70),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: () {
          controller.markAsSettled(loan.id);
          Get.back(); // ডায়ালগ ক্লোজ করবে
        },
        child: const Text(
          'Yes, Settle',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}
