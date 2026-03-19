import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/build_context_extension.dart';
import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/core/theme.dart';
import 'package:nuitri_pilot_frontend/core/theme_control.dart';

class MoreBody extends StatelessWidget {
  const MoreBody({super.key});

  Future<void> _confirmAndLogout(BuildContext context) async {
    if (await context.confirm(message: "You are going to sign out")) {
      Result<Error, bool> result = await DI.I.authService.signOut();
      if(!await DI.I.messageHandler.doIfErr(result)){
        Navigator.pushNamedAndRemoveUntil(context, '/signin', (r) => false);
      }
    }
  }

  void _enterSettings(BuildContext context) {}

  @override
Widget build(BuildContext context) {
  final danger = Theme.of(context).colorScheme.error;

  return ValueListenableBuilder<ThemeMode>(
    valueListenable: ThemeController.notifier,
    builder: (context, mode, _) {
      final isDark = mode == ThemeMode.dark;

      return ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: isDark,
            onChanged: (value) async {
              await ThemeController.setTheme(
                value ? ThemeMode.dark : ThemeMode.light,
              );
            },
          ),
          /*
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => _enterSettings(context),
          ),*/

          ListTile(
            leading: Icon(Icons.logout, color: danger),
            title: Text('Sign Out', style: TextStyle(color: danger)),
            onTap: () => _confirmAndLogout(context),
          ),
        ],
      );
    },
  );
}

}
