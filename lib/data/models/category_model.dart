import 'package:isar/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  // এই ক্যাটাগরির জন্য কাস্টম প্রিসেট অ্যামাউন্টগুলো এখানে থাকবে
  late List<int> presets;
}
