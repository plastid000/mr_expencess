import 'package:isar/isar.dart';

part 'user_settings_model.g.dart';

@collection
class UserSettingsModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? firebaseUid;

  String? email;
  String? photoUrl;

  late String userName;
  late List<String> wallets;
  late List<String> expenseCategories;

  bool isSynced = false;
}
