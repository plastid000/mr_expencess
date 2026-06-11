import 'package:get/get.dart';
import '../../core/services/security_service.dart';
import '../dashboard/dashboard_view.dart';

class LockScreenController extends GetxController {
  final SecurityService security = Get.find<SecurityService>();

  var enteredPin = ''.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    // অ্যাপ ওপেন হলেই যদি বায়োমেট্রিক অন থাকে, অটো ফিঙ্গারপ্রিন্ট চাইবে
    if (security.isBiometricEnabled.value) {
      triggerBiometric();
    }
  }

  Future<void> triggerBiometric() async {
    bool success = await security.authenticateBiometric();
    if (success) {
      unlockApp();
    }
  }

  // কাস্টম কিপ্যাড থেকে নাম্বার ইনপুট নেওয়া
  void addDigit(String digit) {
    if (hasError.value) {
      enteredPin.value = ''; // আগের ভুল পিন ক্লিয়ার করে দিবে
      hasError.value = false;
    }

    if (enteredPin.value.length < security.pinLength.value) {
      enteredPin.value += digit;

      // পিন লেংথ ফিলআপ হলে অটো ভেরিফাই করবে
      if (enteredPin.value.length == security.pinLength.value) {
        verifyPin();
      }
    }
  }

  // পিন মোছা (Backspace)
  void removeDigit() {
    if (enteredPin.value.isNotEmpty) {
      enteredPin.value = enteredPin.value.substring(
        0,
        enteredPin.value.length - 1,
      );
    }
  }

  void verifyPin() {
    if (security.verifyPin(enteredPin.value)) {
      unlockApp();
    } else {
      hasError.value = true;
      Get.snackbar(
        'Error',
        'ভুল পিন দিয়েছেন!',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void unlockApp() {
    // পিন বা বায়োমেট্রিক মিললে ড্যাশবোর্ডে পাঠিয়ে দিবে
    Get.offAll(() => const DashboardView(), transition: Transition.fadeIn);
  }
}
