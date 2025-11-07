import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/build_context_extension.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';

class MoreBody extends StatelessWidget {
  const MoreBody({super.key});

  Future<void> _confirmAndLogout(BuildContext context) async {
    if (await context.confirm(message: "You are going to sign out")) {
      bool success = await DI.I.authService.signOut();
      if (success) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
      }
    }
  }

  void _enterSettings(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    final danger = Theme.of(context).colorScheme.error;
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.settings, color: danger),
          title: Text('Settings', style: TextStyle(color: danger)),
          onTap: () => _enterSettings(context),
        ),
        ListTile(
          leading: Icon(Icons.logout, color: danger),
          title: Text('Sign Out', style: TextStyle(color: danger)),
          onTap: () => _confirmAndLogout(context),
        ),
      ],
    );
  }
}
