
 
 import 'package:flutter/material.dart';

Future<bool> YesOrNo(BuildContext context, 
  { required String title, 
    required String message,
    required String confirmText,
    required String cancelText,
  }) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelText)),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(confirmText)),
            ],
          ),
        ) ??
        false;
      return ok;
 }
 
