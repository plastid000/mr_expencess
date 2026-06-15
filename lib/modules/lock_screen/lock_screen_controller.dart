import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/security_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/update_service.dart'; // 🔥 আপডেট সার্ভিস ইমপোর্ট করা হলো
import '../dashboard/dashboard_view.dart';

class LockScreenController extends GetxController {
  final SecurityService security = Get.find<SecurityService>();

  var enteredPin = ''.obs;
  var hasError = false.obs;
  var keypadNumbers = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _generateRandomKeypad();
    if (security.isBiometricEnabled.value) {
      triggerBiometric();
    }
  }

  void _generateRandomKeypad() {
    List<String> nums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    nums.shuffle();
    keypadNumbers.value = nums;
  }

  Future<void> triggerBiometric() async {
    bool success = await security.authenticateBiometric();
    if (success) unlockApp();
  }

  void addDigit(String value) {
    if (hasError.value) {
      enteredPin.value = '';
      hasError.value = false;
    }
    if (enteredPin.value.length < security.pinLength.value) {
      enteredPin.value += value;
      if (enteredPin.value.length == security.pinLength.value) {
        verifyPin();
      }
    }
  }

  void removeDigit() {
    if (enteredPin.value.isNotEmpty) {
      enteredPin.value = enteredPin.value.substring(
        0,
        enteredPin.value.length - 1,
      );
      hasError.value = false;
    }
  }

  void verifyPin() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (security.verifyPin(enteredPin.value)) {
      unlockApp();
    } else {
      hasError.value = true;
      enteredPin.value = '';
      _generateRandomKeypad();
      Get.snackbar(
        'Error',
        'ভুল পিন দিয়েছেন!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.expenseRed,
        colorText: Colors.white,
      );
    }
  }

  void unlockApp() {
    GetStorage().write('is_locked', false);
    Get.offAll(() => const DashboardView(), transition: Transition.fadeIn);

    // 🔥 ম্যাজিক: আনলক হওয়ার সাথে সাথেই আপডেট চেক ফায়ার করবে!
    if (Get.isRegistered<UpdateService>()) {
      Get.find<UpdateService>().checkForUpdate();
    }
  }

  void forgotPinFlow() {
    String? question = security.getSecurityQuestion();
    if (question == null || question.isEmpty) {
      Get.snackbar(
        'Error',
        'Security question was not set up!',
        backgroundColor: AppColors.expenseRed,
        colorText: Colors.white,
      );
      return;
    }

    final answerCtrl = TextEditingController();

    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      title: 'Forgot PIN? 🔐',
      titleStyle: const TextStyle(
        color: AppColors.neonGreen,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          Text(
            question,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          TextField(
            controller: answerCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter your answer',
              hintStyle: TextStyle(color: Colors.white30),
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
          if (security.verifySecurityAnswer(answerCtrl.text)) {
            Get.back();
            _showNewPinSetup();
          } else {
            Get.snackbar(
              'Error',
              'Incorrect Answer!',
              backgroundColor: AppColors.expenseRed,
              colorText: Colors.white,
            );
          }
        },
        child: const Text(
          'Verify',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  void _showNewPinSetup() {
    final pinCtrl = TextEditingController();
    var step = 1.obs;
    String firstPin = '';

    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      barrierDismissible: false,
      title: 'Set New PIN',
      titleStyle: const TextStyle(
        color: AppColors.neonGreen,
        fontWeight: FontWeight.bold,
      ),
      content: Obx(
        () => Column(
          children: [
            Text(
              step.value == 1
                  ? 'Enter new ${security.pinLength.value}-digit PIN'
                  : 'Re-enter to confirm',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: pinCtrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: security.pinLength.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 8,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: '',
                hintText: '*' * security.pinLength.value,
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
                if (val.length == security.pinLength.value) {
                  if (step.value == 1) {
                    firstPin = val;
                    step.value = 2;
                    Future.microtask(() => pinCtrl.clear());
                  } else if (step.value == 2) {
                    if (val == firstPin) {
                      security.savePin(firstPin, security.pinLength.value);
                      Get.back(); // close dialog
                      unlockApp(); // আনলক এবং আপডেট চেক একসাথে হবে
                      Get.snackbar(
                        'Unlocked! 🔓',
                        'New PIN set successfully.',
                        backgroundColor: AppColors.surface,
                        colorText: AppColors.neonGreen,
                      );
                    } else {
                      Get.snackbar(
                        'Error',
                        'PINs do not match! Try again.',
                        backgroundColor: AppColors.expenseRed,
                        colorText: Colors.white,
                      );
                      step.value = 1;
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
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}
