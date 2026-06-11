import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'analytics_controller.dart';
import '../../core/constants/app_colors.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalyticsController());
    controller.calculateStats();
    controller.calculateMonthlyComparison();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Top Summary Cards
            Obx(
              () => Row(
                children: [
                  _buildSummaryCard(
                    'Income',
                    '৳${controller.totalIncome.value.toStringAsFixed(0)}',
                    AppColors.neonGreen,
                  ),
                  const SizedBox(width: 15),
                  _buildSummaryCard(
                    'Expense',
                    '৳${controller.totalExpense.value.toStringAsFixed(0)}',
                    AppColors.expenseRed,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Category Pie Chart
            const Text(
              'Spending by Category',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: Obx(
                () => PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: controller.categoryData.map((data) {
                      final index = controller.categoryData.indexOf(data);
                      return PieChartSectionData(
                        value: data['value'],
                        title: data['name'],
                        color: _getChartColor(index),
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Monthly Comparison Bar Chart
            const Text(
              'Monthly Trend',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Obx(
                () => BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) => Text(
                            val == 0 ? 'Last Month' : 'This Month',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: controller.barData[0],
                            color: Colors.grey,
                            width: 25,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: controller.barData[1],
                            color: AppColors.neonGreen,
                            width: 25,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Smart Insight Box
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📌 AI Insight',
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => Text(
                      controller.totalExpense.value >
                              controller.totalIncome.value
                          ? "Warning: Your expenses are higher than income!"
                          : "Great! You are managing your finances well.",
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getChartColor(int index) {
    final colors = [
      AppColors.neonGreen,
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
    ];
    return colors[index % colors.length];
  }
}
