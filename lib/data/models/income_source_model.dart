import 'package:isar/isar.dart';

part 'income_source_model.g.dart';

@collection
class IncomeSourceModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;
}
