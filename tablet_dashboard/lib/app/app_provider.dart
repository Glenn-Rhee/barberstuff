import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/features/auth/data/auth_api.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';

/// Every dependency of the till: one API per feature (all sharing [client]),
/// the printer, then the controllers the screens watch.
List<SingleChildWidget> appProviders({
  required ApiClient client,
  required AuthApi authApi,
  // required CatalogApi catalogApi,
  // required BookingApi bookingApi,
  // required CashSessionApi cashSessionApi,
  // PrinterController? printer,
}) {
  return [
    Provider<AuthApi>.value(value: authApi),
    // Provider<CatalogApi>.value(value: catalogApi),
    // Provider<BookingApi>.value(value: bookingApi),
    // Provider<CashSessionApi>.value(value: cashSessionApi),
    // ChangeNotifierProvider(create: (_) => printer ?? PrinterController()),
    // ChangeNotifierProvider(create: (_) => NavigationController()),
    ChangeNotifierProvider(
      create: (_) => SessionController(authApi, client)..restore(),
    ),
    // ChangeNotifierProvider(create: (_) => ShiftController(cashSessionApi)),
    // ChangeNotifierProvider(create: (_) => CatalogController(catalogApi)),
    // ChangeNotifierProvider(create: (_) => OrderController()),
    // ChangeNotifierProvider(create: (_) => BookingsController(bookingApi)),
    Provider(
      create: (ctx) => CheckoutController(
        // bookingApi,
        // ctx.read<ShiftController>(),
        ctx.read<SessionController>(),
      ),
    ),
  ];
}
