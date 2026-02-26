import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/app_router.dart';
import 'core/di.dart';

void main() {
  DI.I.init();
  runApp(const NutriPilot());
}

class NutriPilot extends StatelessWidget {
  const NutriPilot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutri Pilot',
      theme: AppTheme.nutriPilotTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/home',
      debugShowCheckedModeBanner: false,
      navigatorKey: DI.navigatorKey,
      scaffoldMessengerKey: DI.scaffoldMessengerKey,
    );
  }
  
}

