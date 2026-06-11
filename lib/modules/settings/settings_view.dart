import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import '../../core/services/security_service.dart';
import '../../core/constants/app_colors.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
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
                      Get.find<SettingsController>().clearAllData();
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

  // পিন ডায়ালগ (৪, ৬, ৮ ডিজিট সিলেকশন সহ)
  void _showPinSetupDialog(BuildContext context, SecurityService security) {
    final pinCtrl = TextEditingController();
    var selectedLength = 4.obs;

    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      title: 'Set App PIN',
      titleStyle: const TextStyle(color: AppColors.neonGreen),
      content: Column(
        children: [
          const Text(
            'Select PIN Length:',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [4, 6, 8]
                  .map(
                    (len) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ChoiceChip(
                        label: Text('$len'),
                        selected: selectedLength.value == len,
                        onSelected: (selected) => selectedLength.value = len,
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
          ),
          const SizedBox(height: 15),
          TextField(
            controller: pinCtrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'Enter PIN',
              hintStyle: TextStyle(color: Colors.white24),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.neonGreen),
              ),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen),
        onPressed: () {
          if (pinCtrl.text.length != selectedLength.value) {
            Get.snackbar(
              'Error',
              '${selectedLength.value} ডিজিটের পিন দাও!',
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
            return;
          }
          security.savePin(pinCtrl.text, selectedLength.value);
          Get.back();
          Get.snackbar(
            'Success',
            'PIN Lock সাকসেসফুলি সেট হয়েছে!',
            backgroundColor: AppColors.surface,
            colorText: AppColors.neonGreen,
          );
        },
        child: const Text(
          'Save',
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
