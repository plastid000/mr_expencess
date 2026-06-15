import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mr_expense/core/services/backup_restore_service.dart';
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
      // 🔥 জাস্ট এই SingleChildScrollView টা অ্যাড করা হলো
      child: SingleChildScrollView(
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
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white30,
                ),
                onTap: () => _showEditNameDialog(context, controller),
              ),

              const Divider(color: Colors.white12, height: 20),

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
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white30,
                ),
                onTap: () => _showWalletDialog(context, controller),
              ),

              const Divider(color: Colors.white12, height: 20),

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

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.security_outlined,
                  color: AppColors.neonGreen,
                ),
                title: const Text(
                  'Security Question',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                subtitle: const Text(
                  'Set question for offline PIN recovery',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white30,
                ),
                onTap: () => controller.setupSecurityQuestion(),
              ),

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
                    if (!success) {
                      Get.snackbar(
                        'Error',
                        'ডিভাইস সাপোর্ট করছে না!',
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    }
                  },
                ),
              ),

              const Divider(color: Colors.white12, height: 40),

              const Text(
                'Data Management',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // 🔥 Backup Button
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.cloud_upload_outlined,
                  color: AppColors.neonGreen,
                ),
                title: const Text(
                  'Backup Data',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                subtitle: const Text(
                  'Save your data locally',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white30,
                ),
                onTap: () {
                  final backupService = Get.put(BackupRestoreService());
                  backupService.backupData();
                },
              ),

              // 🔥 Restore Button
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.settings_backup_restore,
                  color: Colors.orangeAccent,
                ),
                title: const Text(
                  'Restore Data',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                subtitle: const Text(
                  'Restore from a backup file',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white30,
                ),
                onTap: () {
                  final backupService = Get.put(BackupRestoreService());
                  backupService.restoreData();
                },
              ),

              const Divider(color: Colors.white12, height: 40),

              // 🔥 Clear Data Section With PIN Verification
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
                        Get.back(); // ওয়ার্নিং ডায়ালগ প্রথমে ক্লোজ হবে

                        // এরপর পিন ভেরিফিকেশনের জন্য কল হবে
                        controller.verifyPinAndClear(() {
                          controller.clearAllData();
                          securityService.disableSecurity();
                        });
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
      ),
    );
  }

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
    var step = 1.obs; // 1 = Enter New PIN, 2 = Confirm PIN
    String firstPin = '';

    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      title: 'Set App PIN',
      titleStyle: const TextStyle(
        color: AppColors.neonGreen,
        fontWeight: FontWeight.bold,
      ),
      content: Obx(
        () => Column(
          children: [
            // 🔥 Step 1: Length Selection (২য় স্টেপে এটা হাইড হয়ে যাবে)
            if (step.value == 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [4, 6, 8]
                    .map(
                      (len) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text('$len'),
                          selected: selectedLength.value == len,
                          onSelected: (s) {
                            selectedLength.value = len;
                            pinCtrl.clear();
                          },
                          selectedColor: AppColors.neonGreen,
                          labelStyle: TextStyle(
                            color: selectedLength.value == len
                                ? Colors.black
                                : Colors.white,
                          ),
                          backgroundColor: AppColors.background,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 15),
            ],

            Text(
              step.value == 1
                  ? 'Enter new ${selectedLength.value}-digit PIN'
                  : 'Re-enter to confirm PIN',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 10),

            // 🔥 অটো-ভেরিফাই টেক্সটফিল্ড
            TextField(
              controller: pinCtrl,
              autofocus: true, // ডায়ালগ ওপেন হলেই কিবোর্ড আসবে
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: selectedLength.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 8,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: '', // ম্যাক্স লেন্থ কাউন্টার হাইড করা
                hintText: '*' * selectedLength.value,
                hintStyle: const TextStyle(
                  color: Colors.white24,
                  letterSpacing: 8,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.neonGreen),
                ),
              ),
              onChanged: (val) {
                // ইউজার সিলেক্টেড লেন্থে পৌঁছালেই অটোমেটিক নেক্সট কাজ করবে
                if (val.length == selectedLength.value) {
                  if (step.value == 1) {
                    firstPin = val;
                    step.value = 2; // কনফার্মেশন স্টেপে নিয়ে যাওয়া
                    Future.microtask(
                      () => pinCtrl.clear(),
                    ); // টেক্সটফিল্ড ক্লিয়ার করা
                  } else if (step.value == 2) {
                    if (val == firstPin) {
                      security.savePin(firstPin, selectedLength.value);
                      Get.back();
                      Get.snackbar(
                        'Success! 🔐',
                        'PIN set successfully.',
                        backgroundColor: AppColors.surface,
                        colorText: AppColors.neonGreen,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } else {
                      Get.snackbar(
                        'Error',
                        'PINs do not match! Try again.',
                        backgroundColor: AppColors.expenseRed,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      step.value = 1; // ভুল হলে আবার প্রথম থেকে শুরু
                      firstPin = '';
                      Future.microtask(() => pinCtrl.clear());
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
      // 🔥 সেভ বাটন সরিয়ে দিয়েছি, কারণ সব অটোমেটিক হবে
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}
