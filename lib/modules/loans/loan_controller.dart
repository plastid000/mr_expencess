import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../core/services/database_service.dart';
import '../../data/models/loan_model.dart';
import '../dashboard/dashboard_controller.dart';

class LoanController extends GetxController {
  final Isar _isar = Get.find<DatabaseService>().isar;

  // Observables for real-time UI updates
  var iWillGetLoans = <LoanModel>[].obs;
  var iWillPayLoans = <LoanModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadLoans();
  }

  // ডেটাবেস থেকে শুধু Pending ধারগুলো লোড করবে
  Future<void> loadLoans() async {
    final allLoans = await _isar.loanModels.where().findAll();

    iWillGetLoans.value = allLoans
        .where((l) => l.type == 'I Will Get' && l.status == 'Pending')
        .toList();

    iWillPayLoans.value = allLoans
        .where((l) => l.type == 'I Will Pay' && l.status == 'Pending')
        .toList();
  }

  // নতুন হাওলাত এন্ট্রি করার ফাংশন
  Future<void> addLoan({
    required String name,
    required double amount,
    required String type,
    String? note,
  }) async {
    if (name.isEmpty || amount <= 0) {
      Get.snackbar(
        'Error',
        'নাম আর অ্যামাউন্ট ঠিকমতো বসাও!',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final newLoan = LoanModel()
      ..personName = name
      ..amount = amount
      ..type =
          type // 'I Will Get' or 'I Will Pay'
      ..status = 'Pending'
      ..note = note
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.loanModels.put(newLoan);
    });

    await loadLoans();
    Get.find<DashboardController>().loadDashboardData(); // ড্যাশবোর্ড সিঙ্ক

    Get.back(); // ডায়ালগ বা বটম শিট ক্লোজ করবে
    Get.snackbar(
      'Hawlat Added 📝',
      '$name-এর খাতায় ৳$amount লেখা হয়েছে।',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E1E1E),
      colorText: const Color(0xFF39FF14),
    );
  }

  // টাকা শোধ হয়ে গেলে Settled মার্ক করা
  Future<void> markAsSettled(Id loanId) async {
    await _isar.writeTxn(() async {
      final loan = await _isar.loanModels.get(loanId);
      if (loan != null) {
        loan.status = 'Settled';
        loan.updatedAt = DateTime.now();
        await _isar.loanModels.put(loan);
      }
    });

    await loadLoans();
    Get.find<DashboardController>().loadDashboardData();
  }
}
