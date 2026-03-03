import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/storage/keys.dart';
import 'package:nuitri_pilot_frontend/core/storage/local_storage.dart';
import 'package:uuid/uuid.dart';
import 'core/theme.dart';
import 'core/app_router.dart';
import 'core/di.dart';

Future<void> main() async  {

  WidgetsFlutterBinding.ensureInitialized();
  
  if(!await LocalStorage().containsKey(UUID_KEY)){
    String uuid = Uuid().v4();
    await LocalStorage().put(UUID_KEY, uuid);
  }
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

