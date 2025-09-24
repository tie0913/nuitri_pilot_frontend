import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/app_router.dart';
import 'core/di.dart';

void main() {
  DI.I.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
  
}

