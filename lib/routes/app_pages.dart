import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/dashboard/dashboard_view.dart';
import '../modules/dashboard/dashboard_controller.dart';
import '../modules/expense/expense_view.dart';
import '../modules/income/income_view.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
    ),
    GetPage(name: Routes.ADD_EXPENSE, page: () => const ExpenseView()),
    GetPage(name: Routes.ADD_INCOME, page: () => const IncomeView()),
  ];
}
