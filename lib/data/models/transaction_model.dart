import 'package:isar/isar.dart';
import 'wallet_model.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String type;

  late double amount;
  late String category;

  @Index()
  late DateTime date;

  String? note;

  // 🔥 নতুন ফিল্ড: সহজে রিড করার জন্য ওয়ালেটের নাম
  String? walletName;

  final wallet = IsarLink<WalletModel>();

  DateTime createdAt = DateTime.now();
}
