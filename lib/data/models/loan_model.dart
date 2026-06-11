import 'package:isar/isar.dart';

part 'loan_model.g.dart';

@collection
class LoanModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String personName;

  late double amount;
  late String type; // I Will Get, I Will Pay
  late String status; // Pending, Settled

  DateTime? dueDate;
  String? phone;
  String? note;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
