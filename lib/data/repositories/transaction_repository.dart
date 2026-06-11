import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../core/services/database_service.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

class TransactionRepository {
  final Isar _isar = Get.find<DatabaseService>().isar;

  // নতুন ট্রানজ্যাকশন অ্যাড করার ফাংশন
  Future<void> addTransaction(
    TransactionModel transaction,
    String walletName,
  ) async {
    final wallet = await _isar.walletModels
        .filter()
        .nameEqualTo(walletName)
        .findFirst();

    if (wallet != null) {
      // ওয়ালেট ব্যালেন্স আপডেট লজিক
      if (transaction.type == 'income') {
        wallet.balance += transaction.amount;
      } else if (transaction.type == 'expense') {
        wallet.balance -= transaction.amount;
      }

      // ট্রানজ্যাকশন সেভ এবং ওয়ালেট লিংক করা
      await _isar.writeTxn(() async {
        await _isar.walletModels.put(wallet);
        transaction.wallet.value = wallet;
        await _isar.transactionModels.put(transaction);
        await transaction.wallet.save();
      });
    }
  }

  // সব ট্রানজ্যাকশন রিড করার ফাংশন
  Future<List<TransactionModel>> getAllTransactions() async {
    return await _isar.transactionModels.where().sortByDateDesc().findAll();
  }
}
