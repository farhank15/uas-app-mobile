import 'package:uas_flutter_app/screens/customer/home_screen.dart';
import 'package:uas_flutter_app/screens/customer/add_customer_screen.dart';
import 'package:uas_flutter_app/utils/guard_util.dart';
import 'package:go_router/go_router.dart';

class CustomerRoutes {
  static final List<GoRoute> _routes = [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
      redirect: (context, state) async {
        if (!await Vania.isLoggedIn()) {
          return '/login';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/add-customer',
      builder: (context, state) => const AddCustomerScreen(),
      redirect: (context, state) async {
        if (!await Vania.isLoggedIn()) {
          return '/login';
        }
        return null;
      },
    ),
  ];

  static List<GoRoute> get routes => _routes;
}
