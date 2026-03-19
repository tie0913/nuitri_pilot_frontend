import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/storage/local_storage.dart';

class ThemeController {

  static final String key = "theme_mode";
  static final ValueNotifier<ThemeMode> notifier =
      ValueNotifier(ThemeMode.system);

  static Future<void> setTheme(ThemeMode mode) async {
    String modeText = "light";
    if(mode == ThemeMode.dark){
        modeText  = "dark";
    }
    await LocalStorage().put(key, modeText);
    notifier.value = mode;
  }

  static Future<void> loadTheme() async {
    ThemeMode mode = ThemeMode.light;
    String themeName = await LocalStorage().get(key)??"light";
    if(themeName == "dark"){
      mode = ThemeMode.dark;
    }
    notifier.value = mode;
  }
}