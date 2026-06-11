import 'package:isar/isar.dart';
import 'wallet_model.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String type; // income, expense, loan_given, etc.

  late double amount;
  late String category;

  @Index()
  late DateTime date;

  String? note;

  // IsarLink দিয়ে ওয়ালেটের সাথে ডিরেক্ট কানেকশন
  final wallet = IsarLink<WalletModel>();

  DateTime createdAt = DateTime.now();
}
