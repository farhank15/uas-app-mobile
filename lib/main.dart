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
      initialLocation: '/', // Set the default location
      routes: [
        ...GuestRoutes.routes,
        ...CustomerRoutes.routes,
        // Add a default route to handle '/'
        GoRoute(
          path: '/',
          redirect: (context, state) async {
            if (await Vania.isLoggedIn()) {
              return '/home';
            }
            return '/login';
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
