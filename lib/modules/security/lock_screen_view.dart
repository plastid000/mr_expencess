import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'lock_screen_controller.dart';
import '../../core/constants/app_colors.dart';

class LockScreenView extends StatelessWidget {
  const LockScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LockScreenController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Logo / Lock Icon
            const Icon(
              Icons.lock_outline,
              size: 60,
              color: AppColors.neonGreen,
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter App PIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // PIN Indicator Dots
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.security.pinLength.value,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.enteredPin.value.length > index
                          ? AppColors.neonGreen
                          : (controller.hasError.value
                                ? AppColors.expenseRed
                                : AppColors.surface),
                      border: Border.all(
                        color: controller.hasError.value
                            ? AppColors.expenseRed
                            : AppColors.neonGreen.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Custom Numeric Keypad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) {
                    // Biometric Button
                    return Obx(
                      () => controller.security.isBiometricEnabled.value
                          ? _buildKeypadButton(
                              Icons.fingerprint,
                              () => controller.triggerBiometric(),
                              isIcon: true,
                              color: AppColors.neonGreen,
                            )
                          : const SizedBox.shrink(),
                    );
                  } else if (index == 10) {
                    // Number 0
                    return _buildKeypadButton(
                      '0',
                      () => controller.addDigit('0'),
                    );
                  } else if (index == 11) {
                    // Backspace Button
                    return _buildKeypadButton(
                      Icons.backspace_outlined,
                      () => controller.removeDigit(),
                      isIcon: true,
                    );
                  } else {
                    // Numbers 1-9
                    final number = (index + 1).toString();
                    return _buildKeypadButton(
                      number,
                      () => controller.addDigit(number),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(
    dynamic content,
    VoidCallback onTap, {
    bool isIcon = false,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isIcon
              ? Icon(content as IconData, color: color, size: 28)
              : Text(
                  content as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
