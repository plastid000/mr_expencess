import 'package:flutter/material.dart'; //
import 'package:get/get.dart'; //
import 'package:mr_expense/modules/settings/settings_controller.dart';
import 'expense_controller.dart'; //
import '../../core/constants/app_colors.dart'; //
import '../../data/models/category_model.dart'; //

class ExpenseView extends GetView<ExpenseController> {
  const ExpenseView({super.key}); //

  @override
  Widget build(BuildContext context) {
    Get.put(ExpenseController()); //

    return Scaffold(
      backgroundColor: AppColors.background, //
      appBar: AppBar(
        backgroundColor: AppColors.background, //
        elevation: 0, //
        title: const Text(
          //
          'Add Expense', //
          style: TextStyle(color: AppColors.expenseRed), //
        ),
        iconTheme: const IconThemeData(color: Colors.white), //
      ),
      body: SingleChildScrollView(
        //
        padding: const EdgeInsets.all(20.0), //
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, //
          children: [
            // Wallet Selector
            Row(
              //
              mainAxisAlignment: MainAxisAlignment.spaceBetween, //
              children: [
                const Text(
                  //
                  'Wallet', //
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ), //
                ),
                Obx(
                  //
                  () => DropdownButton<String>(
                    //
                    value: controller.selectedWallet.value, //
                    dropdownColor: AppColors.surface, //
                    underline: const SizedBox(), //
                    style: const TextStyle(
                      //
                      color: AppColors.neonGreen, //
                      fontSize: 16, //
                      fontWeight: FontWeight.bold, //
                    ),
                    items: Get.find<SettingsController>().wallets.map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        controller.selectedWallet.value = val!, //
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), //
            // Categories List with Add Button (Wrap Layout)
            const Text(
              //
              'Category (Long press to delete)', //
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16), //
            ),
            const SizedBox(height: 12), //
            Obx(() {
              //
              return Wrap(
                //
                spacing: 12, //
                runSpacing: 12, //
                children: [
                  ...controller.categories.map((cat) {
                    //
                    final isSelected =
                        controller.selectedCategory.value == cat.name; //
                    return GestureDetector(
                      //
                      onTap: () => controller.changeCategory(cat), //
                      onLongPress: () => _showDeleteDialog(cat), //
                      child: Container(
                        //
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ), //
                        decoration: BoxDecoration(
                          //
                          color: isSelected
                              ? AppColors.expenseRed.withOpacity(0.2)
                              : AppColors.surface, //
                          borderRadius: BorderRadius.circular(25), //
                          border: Border.all(
                            color: isSelected
                                ? AppColors.expenseRed
                                : Colors.transparent,
                          ), //
                        ),
                        child: Text(
                          //
                          cat.name, //
                          style: TextStyle(
                            //
                            color: isSelected
                                ? AppColors.expenseRed
                                : AppColors.textSecondary, //
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal, //
                          ),
                        ),
                      ),
                    );
                  }).toList(), //
                  // Add Button
                  GestureDetector(
                    //
                    onTap: () => _showAddCategoryDialog(context), //
                    child: Container(
                      //
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ), //
                      decoration: BoxDecoration(
                        //
                        color: AppColors.surface, //
                        borderRadius: BorderRadius.circular(25), //
                        border: Border.all(
                          color: AppColors.neonGreen,
                          width: 1.5,
                        ), //
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.neonGreen,
                        size: 20,
                      ), //
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 25), //
            // Description / Note Input Field
            const Text(
              //
              'Note (Optional)', //
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16), //
            ),
            const SizedBox(height: 12), //
            Container(
              //
              padding: const EdgeInsets.symmetric(horizontal: 16), //
              decoration: BoxDecoration(
                //
                color: AppColors.surface, //
                borderRadius: BorderRadius.circular(15), //
              ),
              child: TextField(
                //
                controller: controller.noteController, //
                style: const TextStyle(color: Colors.white, fontSize: 16), //
                decoration: const InputDecoration(
                  //
                  border: InputBorder.none, //
                  hintText: 'e.g., Mama der sathe adda...', //
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 14), //
                ),
              ),
            ),
            const SizedBox(height: 30), //
            // --- Custom Amount Input Section ---
            const Text(
              'Custom Amount',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.neonGreen.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calculate_outlined,
                    color: AppColors.neonGreen,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller.customAmountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: AppColors.neonGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '৳ 0',
                        hintStyle: TextStyle(
                          color: Colors.white30,
                          fontSize: 18,
                        ),
                      ),
                      onSubmitted: (_) => controller.submitCustomAmount(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle,
                      color: AppColors.neonGreen,
                    ),
                    onPressed: () => controller.submitCustomAmount(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Smart Presets Grid
            const Text(
              'Or Tap a Preset',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 12), //
            Obx(() {
              //
              final presets = controller.currentPresets; //

              if (presets.isEmpty) {
                //
                return const Center(
                  //
                  child: Text(
                    //
                    'No presets found.', //
                    style: TextStyle(color: AppColors.textSecondary), //
                  ),
                );
              }

              return GridView.builder(
                //
                shrinkWrap: true, //
                physics: const NeverScrollableScrollPhysics(), //
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //
                  crossAxisCount: 3, //
                  crossAxisSpacing: 15, //
                  mainAxisSpacing: 15, //
                  childAspectRatio: 2, //
                ),
                itemCount: presets.length, //
                itemBuilder: (context, index) {
                  //
                  final amount = presets[index]; //
                  return GestureDetector(
                    //
                    onTap: () => controller.saveExpense(
                      amount.toDouble(),
                    ), // আপডেট করা কল
                    child: Container(
                      //
                      decoration: BoxDecoration(
                        //
                        color: AppColors.surface, //
                        borderRadius: BorderRadius.circular(15), //
                      ),
                      child: Center(
                        //
                        child: Text(
                          //
                          '৳$amount', //
                          style: const TextStyle(
                            //
                            color: Colors.white, //
                            fontSize: 20, //
                            fontWeight: FontWeight.bold, //
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 20), //
          ],
        ),
      ),
    );
  }

  // Add Category Dialog
  void _showAddCategoryDialog(BuildContext context) {
    //
    final nameCtrl = TextEditingController(); //
    final presetsCtrl = TextEditingController(); //

    Get.defaultDialog(
      //
      backgroundColor: AppColors.surface, //
      title: 'New Category', //
      titleStyle: const TextStyle(color: AppColors.neonGreen), //
      content: Column(
        //
        children: [
          TextField(
            //
            controller: nameCtrl, //
            style: const TextStyle(color: Colors.white), //
            decoration: const InputDecoration(
              //
              hintText: 'Category Name (e.g. Bus)', //
              hintStyle: TextStyle(color: Colors.white30), //
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ), //
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.neonGreen),
              ), //
            ),
          ),
          const SizedBox(height: 10), //
          TextField(
            //
            controller: presetsCtrl, //
            style: const TextStyle(color: Colors.white), //
            keyboardType: TextInputType.number, //
            decoration: const InputDecoration(
              //
              hintText: 'Presets (e.g. 10, 20, 50)', //
              hintStyle: TextStyle(color: Colors.white30), //
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ), //
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.neonGreen),
              ), //
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        //
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonGreen,
        ), //
        onPressed: () => Get.find<ExpenseController>().addNewCategory(
          nameCtrl.text,
          presetsCtrl.text,
        ), //
        child: const Text(
          'Add',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ), //
      ),
      cancel: TextButton(
        //
        onPressed: () => Get.back(), //
        child: const Text('Cancel', style: TextStyle(color: Colors.white70)), //
      ),
    );
  }

  // Delete Category Dialog
  void _showDeleteDialog(CategoryModel cat) {
    //
    Get.defaultDialog(
      //
      backgroundColor: AppColors.surface, //
      title: 'Delete Category', //
      titleStyle: const TextStyle(color: AppColors.expenseRed), //
      middleText: 'Are you sure you want to delete ${cat.name}?', //
      middleTextStyle: const TextStyle(color: Colors.white), //
      confirm: ElevatedButton(
        //
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.expenseRed,
        ), //
        onPressed: () =>
            Get.find<ExpenseController>().deleteCategory(cat.id), //
        child: const Text(
          'Delete',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ), //
      ),
      cancel: TextButton(
        //
        onPressed: () => Get.back(), //
        child: const Text('Cancel', style: TextStyle(color: Colors.white70)), //
      ),
    );
  }
}
