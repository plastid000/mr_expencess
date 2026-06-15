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

            // PIN Dots Indicator
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(controller.security.pinLength.value, (
                  index,
                ) {
                  bool isFilled = index < controller.enteredPin.value.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? AppColors.neonGreen
                          : Colors.transparent,
                      border: Border.all(
                        color: controller.hasError.value
                            ? AppColors.expenseRed
                            : AppColors.neonGreen,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            ),

            const Spacer(),

            // 🔥 Randomized Keypad Layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Obx(() {
                if (controller.keypadNumbers.isEmpty) return const SizedBox();
                return GridView.builder(
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
                      return Obx(
                        () => controller.security.isBiometricEnabled.value
                            ? _buildKeypadButton(
                                Icons.fingerprint,
                                () => controller.triggerBiometric(),
                                isIcon: true,
                                color: AppColors.neonGreen,
                              )
                            : const SizedBox(),
                      );
                    }
                    if (index == 10)
                      return _buildKeypadButton(
                        controller.keypadNumbers[9],
                        () => controller.addDigit(controller.keypadNumbers[9]),
                      );
                    if (index == 11) {
                      return _buildKeypadButton(
                        Icons.backspace_outlined,
                        () => controller.removeDigit(),
                        isIcon: true,
                        color: AppColors.expenseRed,
                      );
                    }
                    return _buildKeypadButton(
                      controller.keypadNumbers[index],
                      () =>
                          controller.addDigit(controller.keypadNumbers[index]),
                    );
                  },
                );
              }),
            ),

            // 🔥 Forgot PIN Option
            TextButton(
              onPressed: controller.forgotPinFlow,
              style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),
              child: const Text(
                'Forgot PIN?',
                style: TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
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
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
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
