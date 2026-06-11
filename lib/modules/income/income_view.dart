import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'income_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/income_source_model.dart';

class IncomeView extends GetView<IncomeController> {
  const IncomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(IncomeController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Add Income',
          style: TextStyle(color: AppColors.neonGreen),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Input
            Center(
              child: SizedBox(
                width: 200,
                child: TextField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  autofocus: true,
                  decoration: const InputDecoration(
                    prefixText: '৳ ',
                    prefixStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 40,
                    ),
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Wallet Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deposit To',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                Obx(
                  () => DropdownButton<String>(
                    value: controller.selectedWallet.value,
                    dropdownColor: AppColors.surface,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    items: ['Cash', 'bKash', 'Nagad', 'Bank'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) => controller.selectedWallet.value = val!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Dynamic Source Categories (Wrap Layout)
            const Text(
              'Source (Long press to delete)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ...controller.sources.map((source) {
                    final isSelected =
                        controller.selectedSource.value == source.name;
                    return GestureDetector(
                      onTap: () => controller.changeSource(source.name),
                      onLongPress: () => _showDeleteDialog(source),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.neonGreen.withOpacity(0.2)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.neonGreen
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          source.name,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.neonGreen
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // Add Button
                  GestureDetector(
                    onTap: () => _showAddSourceDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: AppColors.neonGreen,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.neonGreen,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 30),

            // Note Input Field
            const Text(
              'Note (Optional)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: controller.noteController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'e.g., CMS Project Advance...',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: controller.saveIncome,
                child: const Text(
                  'Save Income',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Add Source Dialog
  void _showAddSourceDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      title: 'New Source',
      titleStyle: const TextStyle(color: AppColors.neonGreen),
      content: TextField(
        controller: nameCtrl,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Source Name (e.g. Upwork)',
          hintStyle: TextStyle(color: Colors.white30),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.neonGreen),
          ),
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen),
        onPressed: () =>
            Get.find<IncomeController>().addNewSource(nameCtrl.text),
        child: const Text(
          'Add',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  // Delete Source Dialog
  void _showDeleteDialog(IncomeSourceModel source) {
    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      title: 'Delete Source',
      titleStyle: const TextStyle(color: AppColors.expenseRed),
      middleText: 'Are you sure you want to delete ${source.name}?',
      middleTextStyle: const TextStyle(color: Colors.white),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.expenseRed),
        onPressed: () => Get.find<IncomeController>().deleteSource(source.id),
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
