import 'package:flutter/material.dart';
import 'package:uas_flutter_app/routes/customer_route.dart';
import 'package:uas_flutter_app/routes/guest_route.dart';
import 'package:go_router/go_router.dart';
import 'package:uas_flutter_app/utils/guard_util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) async {
            if (await Vania.isLoggedIn()) {
              return '/home';
            }
            return '/login';
          },
        ),
        ...CustomerRoutes.routes,
        ...GuestRoutes.routes,
      ],
    );

    return MaterialApp.router(
      title: 'Customer Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
