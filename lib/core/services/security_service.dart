import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService extends GetxService {
  final _box = GetStorage();
  final LocalAuthentication _auth = LocalAuthentication();

  var isPinEnabled = false.obs;
  var isBiometricEnabled = false.obs;
  var pinLength = 4.obs; // ৪, ৬, বা ৮ ডিজিট

  Future<SecurityService> init() async {
    await GetStorage.init();
    isPinEnabled.value = _box.read('isPinEnabled') ?? false;
    isBiometricEnabled.value = _box.read('isBiometricEnabled') ?? false;
    pinLength.value = _box.read('pinLength') ?? 4;
    return this;
  }

  // পিন সেট করার ফাংশন
  void savePin(String pin, int length) {
    _box.write('user_pin', pin);
    _box.write('pinLength', length);
    _box.write('isPinEnabled', true);
    isPinEnabled.value = true;
    pinLength.value = length;
  }

  // পিন ভেরিফাই করা
  bool verifyPin(String inputPin) {
    final savedPin = _box.read('user_pin');
    return savedPin == inputPin;
  }

  // বায়োমেট্রিক টগল
  Future<bool> toggleBiometric(bool value) async {
    bool canAuthenticate =
        await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    if (!canAuthenticate) return false;

    _box.write('isBiometricEnabled', value);
    isBiometricEnabled.value = value;
    return true;
  }

  // =========================
  // BIOMETRIC AUTH
  // =========================
  Future<bool> authenticateBiometric() async {
    try {
      final bool canAuth =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

      if (!canAuth) return false;

      return await _auth.authenticate(
        localizedReason: 'App লক আনলক করতে ফিঙ্গারপ্রিন্ট বা ফেস আইডি দিন',
        biometricOnly: true,
        persistAcrossBackgrounding: true, // 3.0.1 এ stickyAuth এর নতুন নাম
      );
    } catch (e) {
      return false;
    }
  }

  // সব সিকিউরিটি রিসেট
  void disableSecurity() {
    _box.remove('user_pin');
    _box.write('isPinEnabled', false);
    _box.write('isBiometricEnabled', false);
    isPinEnabled.value = false;
    isBiometricEnabled.value = false;
  }
}
