import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/core/network/server_clock.dart';
import 'package:tablet_dashboard/core/services/printer/printer_controller.dart';
import 'package:tablet_dashboard/features/admin/branch_list/data/branch_api.dart';
import 'package:tablet_dashboard/features/admin/branch_list/presentation/provider/branch_list_controller.dart';
import 'package:tablet_dashboard/features/auth/login/data/auth_api.dart';
import 'package:tablet_dashboard/features/auth/login/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/cashier/attendance/presentation/provider/attendance_controller.dart';
import 'package:tablet_dashboard/features/cashier/bookkeeping/presentation/provider/cash_history_controller.dart';
import 'package:tablet_dashboard/features/cashier/catalog/data/catalog_api.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/customer_list/data/customer_api.dart';
import 'package:tablet_dashboard/features/cashier/customer_list/presentation/provider/customer_history_controller.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/provider/dashboard_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/provider/checkout_controller.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/data/booking_api.dart';
import 'package:tablet_dashboard/features/cashier/order_reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/order_walk_in/presentation/provider/order_controller.dart';
import 'package:tablet_dashboard/features/cashier/shift/data/cash_session_api.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/features/cashier/store/data/store_api.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/provider/store_controller.dart';
import 'package:tablet_dashboard/features/home/shell/presentation/provider/navigation_controller.dart';

// Semua dependency: API (satu [client]), printer, controller
List<SingleChildWidget> appProviders({
  required ApiClient client,
  required AuthApi authApi,
  required CatalogApi catalogApi,
  required BookingApi bookingApi,
  required CashSessionApi cashSessionApi,
  required StoreApi storeApi,
  required CustomerApi customerApi,
  required BranchApi branchApi,
  PrinterController? printer,
}) {
  return [
    Provider<AuthApi>.value(value: authApi),
    Provider<CatalogApi>.value(value: catalogApi),
    Provider<BookingApi>.value(value: bookingApi),
    Provider<CashSessionApi>.value(value: cashSessionApi),
    Provider<StoreApi>.value(value: storeApi),
    Provider<CustomerApi>.value(value: customerApi),
    Provider<BranchApi>.value(value: branchApi),
    ChangeNotifierProvider<ServerClock>.value(value: client.clock),
    ChangeNotifierProvider(create: (_) => printer ?? PrinterController()),
    ChangeNotifierProvider(create: (_) => NavigationController()),
    ChangeNotifierProvider(
      create: (_) => SessionController(authApi, client)..restore(),
    ),
    ChangeNotifierProvider(create: (_) => ShiftController(cashSessionApi)),
    ChangeNotifierProvider(
      create: (_) => CashHistoryController(cashSessionApi),
    ),
    ChangeNotifierProvider(create: (_) => CatalogController(catalogApi)),
    ChangeNotifierProvider(create: (_) => OrderController()),
    ChangeNotifierProvider(create: (_) => BookingsController(bookingApi)),
    ChangeNotifierProvider(create: (_) => StoreController(storeApi)),
    ChangeNotifierProvider(
      create: (ctx) => AttendanceController(ctx.read<CatalogController>()),
    ),
    ChangeNotifierProvider(create: (_) => DashboardController(bookingApi)),
    ChangeNotifierProvider(
      create: (_) => CustomerHistoryController(customerApi),
    ),
    ChangeNotifierProvider(create: (_) => BranchListController(branchApi)),
    Provider(
      create: (ctx) => CheckoutController(
        bookingApi,
        ctx.read<ShiftController>(),
        ctx.read<SessionController>(),
        ctx.read<StoreController>(),
        client.clock,
      ),
    ),
  ];
}
