import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class AppFlushbar {
  static void show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: backgroundColor ?? colorScheme.primary,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(12),
    ).show(context);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message);
  }

  static void error(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    show(
      context,
      message: message,
      backgroundColor: colorScheme.error,
    );
  }
}