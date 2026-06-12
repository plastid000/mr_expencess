import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import '../../core/services/security_service.dart';
import '../../core/constants/app_colors.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final securityService = Get.find<SecurityService>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // 🔥 প্রোফাইল নেম আপডেট সেকশন
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.person_outline,
                color: AppColors.neonGreen,
              ),
              title: const Text(
                'Change Profile Name',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              subtitle: Obx(
                () => Text(
                  'Current: ${controller.userName.value}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white30),
              onTap: () => _showEditNameDialog(context, controller),
            ),

            const Divider(color: Colors.white12, height: 20),

            // 🔥 Manage Wallets সেকশন
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.neonGreen,
              ),
              title: const Text(
                'Manage Wallets',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              subtitle: Obx(
                () => Text(
                  'Total: ${controller.wallets.length} wallets',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white30),
              onTap: () => _showWalletDialog(context, controller),
            ),

            const Divider(color: Colors.white12, height: 20),

            // পিন সেটআপ অপশন
            Obx(
              () => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline, color: Colors.white),
                title: const Text(
                  'Setup PIN Lock',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                subtitle: Text(
                  securityService.isPinEnabled.value
                      ? 'Status: Active (${securityService.pinLength.value} Digits)'
                      : 'Status: Disabled',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white30,
                ),
                onTap: () => _showPinSetupDialog(context, securityService),
              ),
            ),

            // বায়োমেট্রিক টগল
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.fingerprint, color: Colors.white),
                title: const Text(
                  'Biometric Login',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                value: securityService.isBiometricEnabled.value,
                activeColor: AppColors.neonGreen,
                onChanged: (val) async {
                  if (securityService.isPinEnabled.value == false) {
                    Get.snackbar(
                      'Error',
                      'বায়োমেট্রিক অন করার আগে পিন সেট করো!',
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  bool success = await securityService.toggleBiometric(val);
                  if (!success)
                    Get.snackbar(
                      'Error',
                      'ডিভাইস সাপোর্ট করছে না!',
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                },
              ),
            ),

            const Divider(color: Colors.white12, height: 40),

            // ডেটা ক্লিয়ার বাটন
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.delete_forever_outlined,
                color: AppColors.expenseRed,
              ),
              title: const Text(
                'Clear All Data',
                style: TextStyle(color: AppColors.expenseRed, fontSize: 16),
              ),
              onTap: () {
                Get.defaultDialog(
                  backgroundColor: AppColors.surface,
                  title: 'Warning!',
                  titleStyle: const TextStyle(color: AppColors.expenseRed),
                  middleText: 'সব ডেটা পার্মানেন্টলি ডিলিট হয়ে যাবে। শিওর?',
                  middleTextStyle: const TextStyle(color: Colors.white),
                  confirm: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.expenseRed,
                    ),
                    onPressed: () {
                      controller.clearAllData();
                      securityService.disableSecurity();
                      Get.back();
                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  cancel: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ওয়ালেট ম্যানেজমেন্ট ডায়ালগ
  void _showWalletDialog(BuildContext context, SettingsController controller) {
    final walletCtrl = TextEditingController();
    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      title: 'Your Wallets',
      titleStyle: const TextStyle(
        color: AppColors.neonGreen,
        fontWeight: FontWeight.bold,
      ),
      content: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.wallets.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        controller.wallets[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.expenseRed,
                        ),
                        onPressed: () =>
                            controller.removeWallet(controller.wallets[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
            TextField(
              controller: walletCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'New Wallet Name',
                hintStyle: TextStyle(color: Colors.white30),
              ),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen),
        onPressed: () {
          controller.addWallet(walletCtrl.text.trim());
          walletCtrl.clear();
        },
        child: const Text('Add', style: TextStyle(color: Colors.black)),
      ),
    );
  }

  void _showEditNameDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    final nameInputCtrl = TextEditingController(
      text: controller.userName.value,
    );
    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      title: 'Update Name',
      titleStyle: const TextStyle(
        color: AppColors.neonGreen,
        fontWeight: FontWeight.bold,
      ),
      content: TextField(
        controller: nameInputCtrl,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Enter new name',
          hintStyle: TextStyle(color: Colors.white30),
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen),
        onPressed: () async {
          await controller.updateName(nameInputCtrl.text.trim());
          Get.back();
        },
        child: const Text(
          'Save',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showPinSetupDialog(BuildContext context, SecurityService security) {
    final pinCtrl = TextEditingController();
    var selectedLength = 4.obs;
    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      title: 'Set App PIN',
      titleStyle: const TextStyle(color: AppColors.neonGreen),
      content: Column(
        children: [
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [4, 6, 8]
                  .map(
                    (len) => ChoiceChip(
                      label: Text('$len'),
                      selected: selectedLength.value == len,
                      onSelected: (s) => selectedLength.value = len,
                      selectedColor: AppColors.neonGreen,
                    ),
                  )
                  .toList(),
            ),
          ),
          TextField(
            controller: pinCtrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen),
        onPressed: () {
          security.savePin(pinCtrl.text, selectedLength.value);
          Get.back();
        },
        child: const Text('Save', style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
