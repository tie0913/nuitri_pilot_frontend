import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/app_config.dart';
import 'package:nuitri_pilot_frontend/core/env_loader.dart';
import 'package:nuitri_pilot_frontend/core/storage/keys.dart';
import 'package:nuitri_pilot_frontend/core/storage/local_storage.dart';
import 'package:nuitri_pilot_frontend/core/theme_control.dart';
import 'package:uuid/uuid.dart';
import 'core/theme.dart';
import 'core/app_router.dart';
import 'core/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvLoader.init();
  print(AppConfig.baseUrl);
  if (!await LocalStorage().containsKey(UUID_KEY)) {
    String uuid = Uuid().v4();
    await LocalStorage().put(UUID_KEY, uuid);
  }
  ThemeController.loadTheme();
  DI.I.init();
  runApp(const NutriPilot());
}
class NutriPilot extends StatelessWidget {
  const NutriPilot({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeController.notifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Nutri Pilot',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: '/home',
          debugShowCheckedModeBanner: false,
          navigatorKey: DI.navigatorKey,
          scaffoldMessengerKey: DI.scaffoldMessengerKey,
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: const _NoStretchScrollBehavior(),
              child: child!,
            );
          },
        );
      },
    );
  }
}

class _NoStretchScrollBehavior extends ScrollBehavior {
  const _NoStretchScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics(); 
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
