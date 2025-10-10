import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/widgets/alert.dart';

extension ConfirmX on BuildContext {
  Future<bool> confirm({
    String title = 'Confirmation!',
    required String message,
    String confirmText="Yes",
    String cancelText="No",
  }) => YesOrNo(this,  title: title, message: message,
                          confirmText: confirmText, cancelText: cancelText);
}