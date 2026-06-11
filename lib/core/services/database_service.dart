import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../../data/models/loan_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/income_source_model.dart'; // নতুন মডেল ইমপোর্ট

class DatabaseService extends GetxService {
  late Isar isar;

  Future<DatabaseService> init() async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open([
      TransactionModelSchema,
      WalletModelSchema,
      LoanModelSchema,
      CategoryModelSchema,
      IncomeSourceModelSchema, // ইনকাম সোর্স স্কিমা অ্যাড করা হলো
    ], directory: dir.path);

    // Initial Default Wallets
    if (await isar.walletModels.count() == 0) {
      await isar.writeTxn(() async {
        await isar.walletModels.putAll([
          WalletModel()
            ..name = 'Cash'
            ..balance = 0.0,
          WalletModel()
            ..name = 'bKash'
            ..balance = 0.0,
          WalletModel()
            ..name = 'Nagad'
            ..balance = 0.0,
          WalletModel()
            ..name = 'Bank'
            ..balance = 0.0,
        ]);
      });
    }

    // Initial Default Categories
    if (await isar.categoryModels.count() == 0) {
      await isar.writeTxn(() async {
        await isar.categoryModels.putAll([
          CategoryModel()
            ..name = 'Rickshaw'
            ..presets = [20, 30, 40, 50, 60, 100],
          CategoryModel()
            ..name = 'Food'
            ..presets = [50, 100, 150, 200, 300, 500],
          CategoryModel()
            ..name = 'Private'
            ..presets = [500, 1000, 1500],
          CategoryModel()
            ..name = 'Others'
            ..presets = [10, 20, 50, 100],
        ]);
      });
    }

    // Initial Default Income Sources
    if (await isar.incomeSourceModels.count() == 0) {
      await isar.writeTxn(() async {
        await isar.incomeSourceModels.putAll([
          IncomeSourceModel()..name = 'Basa',
          IncomeSourceModel()..name = 'Tuition',
          IncomeSourceModel()..name = 'Freelancing',
          IncomeSourceModel()..name = 'Project',
        ]);
      });
    }

    return this;
  }
}
