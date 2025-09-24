// lib/core/app_router.dart
import 'package:flutter/material.dart';
import '../features/home/presentation/home_page.dart';
import '../features/auth/presentation/signin_page.dart';
import 'require_auth.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/home':
        return _guarded((_) => const HomePage()); // 受保护
      case '/signin':
        return MaterialPageRoute(builder: (_) => const SignInPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }

  static MaterialPageRoute _guarded(WidgetBuilder pageBuilder) {
    return MaterialPageRoute(
      builder: (_) => RequireAuth(builder: pageBuilder, redirectTo: '/signin'),
    );
  }
}
