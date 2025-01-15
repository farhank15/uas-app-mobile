import 'package:uas_flutter_app/screens/guest/auth/login_screen.dart';
import 'package:uas_flutter_app/screens/guest/auth/register_screen.dart';
import 'package:uas_flutter_app/utils/guard_util.dart';
import 'package:go_router/go_router.dart';

class GuestRoutes {
  static final List<GoRoute> _routes = [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
      redirect: (context, state) async {
        if (await Vania.isLoggedIn()) {
          return '/home';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
      redirect: (context, state) async {
        if (await Vania.isLoggedIn()) {
          return '/home';
        }
        return null;
      },
    ),
  ];

  static List<GoRoute> get routes => _routes;
}
