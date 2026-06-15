import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:mr_expense/core/constants/app_colors.dart';
import 'package:mr_expense/data/models/loan_model.dart';
import 'package:mr_expense/modules/dashboard/dashboard_controller.dart';
import 'package:mr_expense/modules/loans/loan_controller.dart';
import '../../core/services/database_service.dart';
import '../../core/services/security_service.dart'; // 🔥 সিকিউরিটি সার্ভিস ইমপোর্ট করা হলো
import '../../data/models/user_settings_model.dart';

class SettingsController extends GetxController {
  final Isar _isar = Get.find<DatabaseService>().isar;

  // Observables for UI binding
  var userName = 'Rahat'.obs;
  var wallets = <String>[].obs;
  var expenseCategories = <String>[].obs;

  var userEmail = 'local@mrtechbd.net'.obs;
  var userPhotoUrl = ''.obs;

  int? _currentLocalId;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    var settings = await _isar.userSettingsModels.where().findFirst();

    if (settings == null) {
      settings = UserSettingsModel()
        ..firebaseUid = 'local_user_only'
        ..email = 'local@mrtechbd.net'
        ..photoUrl = ''
        ..userName = 'Rahat'
        ..wallets = ['Cash', 'bKash', 'Nagad', 'Bank']
        ..expenseCategories = ['Food', 'Transport', 'Bills']
        ..isSynced = false;

      await _isar.writeTxn(() async {
        _currentLocalId = await _isar.userSettingsModels.put(settings!);
      });
    } else {
      _currentLocalId = settings.id;
    }

    userName.value = settings.userName;
    userEmail.value = settings.email ?? 'local@mrtechbd.net';
    userPhotoUrl.value = settings.photoUrl ?? '';
    wallets.assignAll(settings.wallets);
    expenseCategories.assignAll(settings.expenseCategories);
  }

  Future<void> updateName(String newName) async {
    if (newName.isEmpty) return;
    userName.value = newName;
    await _updateDatabase();
  }

  Future<void> addWallet(String walletName) async {
    if (walletName.isEmpty || wallets.contains(walletName)) return;
    wallets.add(walletName);
    await _updateDatabase();
  }

  Future<void> removeWallet(String walletName) async {
    if (wallets.length <= 1) {
      Get.snackbar(
        'Error',
        'অন্তত একটি ওয়ালেট থাকতে হবে!',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    wallets.remove(walletName);
    await _updateDatabase();
  }

  Future<void> addCategory(String categoryName) async {
    if (categoryName.isEmpty || expenseCategories.contains(categoryName)) {
      return;
    }
    expenseCategories.add(categoryName);
    await _updateDatabase();
  }

  Future<void> removeCategory(String categoryName) async {
    if (expenseCategories.length <= 1) {
      Get.snackbar(
        'Error',
        'অন্তত একটি ক্যাটাগরি রাখুন!',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    expenseCategories.remove(categoryName);
    await _updateDatabase();
  }

  Future<void> _updateDatabase() async {
    if (_currentLocalId == null) return;

    final existingSettings = await _isar.userSettingsModels.get(
      _currentLocalId!,
    );
    if (existingSettings != null) {
      existingSettings.userName = userName.value;
      existingSettings.wallets = wallets.toList();
      existingSettings.expenseCategories = expenseCategories.toList();
      existingSettings.isSynced = false;

      await _isar.writeTxn(() async {
        await _isar.userSettingsModels.put(existingSettings);
      });
    }
  }

  // সব ডেটা ক্লিয়ার/রিসেট
  Future<void> clearAllData() async {
    await _isar.writeTxn(() async {
      await _isar.userSettingsModels.clear();
      await _isar.loanModels.clear();
      await _isar.clear();
    });
    await loadSettings();

    // ડ্যাশবোর্ড কন্ট্রোলারকে রিলোড করার ইনস্ট্রাকশন
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadDashboardData();
    }

    if (Get.isRegistered<LoanController>()) {
      Get.find<LoanController>().loadLoans();
    }

    Get.snackbar(
      'Success',
      'সব লোকাল ডেটা রিসেট করা হয়েছে।',
      backgroundColor: Colors.orangeAccent,
      colorText: Colors.black,
    );
  }

  // 🔥 ডেটা ডিলিট করার আগে পিন ভেরিফাই করার মেথড (আপডেটেড উইথ হ্যাশিং)
  void verifyPinAndClear(VoidCallback onSuccess) {
    final security =
        Get.find<SecurityService>(); // সিকিউরিটি সার্ভিস কল করা হলো

    // যদি পিন সেট করা না থাকে, তাহলে সরাসরি ডিলিট করে দেবে
    if (!security.isPinEnabled.value) {
      onSuccess();
      return;
    }

    TextEditingController pinCtrl = TextEditingController();

    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      title: 'Verify PIN',
      titleStyle: const TextStyle(
        color: AppColors.expenseRed,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          const Text(
            'সব ডেটা ডিলিট করতে পিন দিন',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: pinCtrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 5,
            ),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: '****',
              hintStyle: TextStyle(color: Colors.white30, letterSpacing: 2),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.expenseRed),
              ),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.expenseRed),
        onPressed: () {
          // 🔥 প্লেইন টেক্সট চেকের বদলে সিকিউরিটি সার্ভিসের এনক্রিপ্টেড চেক!
          if (security.verifyPin(pinCtrl.text)) {
            Get.back(); // পিন ডায়ালগ ক্লোজ
            onSuccess(); // ডিলিট ফাংশন রান
          } else {
            Get.snackbar(
              'Error',
              'Incorrect PIN!',
              backgroundColor: AppColors.expenseRed,
              colorText: Colors.white,
            );
          }
        },
        child: const Text(
          'Delete Data',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  void setupSecurityQuestion() {
    final security = Get.find<SecurityService>();

    // 🔥 ডিফল্ট কিছু সিকিউরিটি প্রশ্ন
    final predefinedQuestions = [
      'What is your favorite teacher\'s name?',
      'What is the name of your first pet?',
      'In what city were you born?',
      'What is your favorite food?',
      'Custom Question...', // এইটা সিলেক্ট করলে টাইপ করার অপশন আসবে
    ];

    // স্টেট ম্যানেজ করার জন্য observables
    var selectedQuestion = predefinedQuestions[0].obs;
    var isCustom = false.obs;

    final customQuestionCtrl = TextEditingController();
    final answerCtrl = TextEditingController();

    // 🔥 যদি আগে থেকে কোনো প্রশ্ন সেভ করা থাকে, সেটা প্রি-ফিল করা
    String? existingQ = security.getSecurityQuestion();
    if (existingQ != null && existingQ.isNotEmpty) {
      if (predefinedQuestions.contains(existingQ)) {
        selectedQuestion.value = existingQ;
      } else {
        selectedQuestion.value = 'Custom Question...';
        isCustom.value = true;
        customQuestionCtrl.text = existingQ;
      }
    }

    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      title: 'Security Question',
      titleStyle: const TextStyle(
        color: AppColors.neonGreen,
        fontWeight: FontWeight.bold,
      ),
      content: Obx(
        () => Column(
          children: [
            // 🔥 Dropdown Menu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  value: selectedQuestion.value,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.neonGreen,
                  ),
                  items: predefinedQuestions.map((String q) {
                    return DropdownMenuItem<String>(
                      value: q,
                      child: Text(
                        q,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      selectedQuestion.value = val;
                      isCustom.value = (val == 'Custom Question...');
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),

            // 🔥 Custom Question TextField (শুধুমাত্র Custom সিলেক্ট করলে দেখাবে)
            if (isCustom.value) ...[
              TextField(
                controller: customQuestionCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Type your custom question',
                  hintStyle: TextStyle(color: Colors.white30),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neonGreen),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],

            // 🔥 Answer TextField
            TextField(
              controller: answerCtrl,
              obscureText:
                  true, // সিকিউরিটির জন্য টাইপ করার সময় আনসার হাইড থাকবে
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Your Answer',
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
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen),
        onPressed: () {
          // কাস্টম সিলেক্ট করলে টেক্সটফিল্ডের ডাটা নিবে, নাহলে ড্রপডাউনের ডাটা নিবে
          String finalQuestion = isCustom.value
              ? customQuestionCtrl.text.trim()
              : selectedQuestion.value;
          String answer = answerCtrl.text.trim();

          if (finalQuestion.isNotEmpty && answer.isNotEmpty) {
            security.saveSecurityQuestion(finalQuestion, answer);
            Get.back();
            Get.snackbar(
              'Saved',
              'Security question updated securely.',
              backgroundColor: AppColors.neonGreen,
              colorText: Colors.black,
            );
          } else {
            Get.snackbar(
              'Error',
              'Please fill all fields!',
              backgroundColor: AppColors.expenseRed,
              colorText: Colors.white,
            );
          }
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
