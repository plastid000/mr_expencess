import 'package:isar/isar.dart';

part 'wallet_model.g.dart';

@collection
class WalletModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  late double balance;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
