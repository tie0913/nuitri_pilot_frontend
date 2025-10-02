// lib/core/app_router.dart
import 'package:flutter/material.dart';
import 'require_auth.dart';
import '../features/home/presentation/home_page.dart';
import '../features/user/presentation/signin_page.dart';
import '../features/user/presentation/forget_password_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/home':
        return _guarded((_) => const HomePage()); // 受保护
      case '/signin':
        return MaterialPageRoute(builder: (_) => const SignInPage());
      case '/forgetPassword':
        return MaterialPageRoute(builder: (_) => const ForgetPasswordPage());
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
