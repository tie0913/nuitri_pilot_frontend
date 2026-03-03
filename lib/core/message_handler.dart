import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:another_flushbar/flushbar.dart';

abstract interface class MessageHandler {

  bool doIfErr(Result<Error, dynamic> result);

  /*
   * 显示一个信息
   */
  void showMessage(String message);
}

class GlobalMessageHandler implements MessageHandler {
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  GlobalMessageHandler({
    required this.navigatorKey,
    required this.messengerKey,
  });

  /// 前后端错误提示分离
  ///
  /// 因为前端多为校验错误，后端一般业务进行不下去了，所以后端用弹出对话框，前端用顶部滑出
  @override
  bool doIfErr(Result<Error, dynamic> result) {
    if(result is Err) {
      Err err = (result as Err);
      final message = getErrorMessage(err.error);
      if(err.error is AppError){
        showAppErr(message);
      }else{
        showBackendErr(message);
      }
      return true;
    }
    return false;
  }

  void showAppErr(String message) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.red,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(12),
    ).show(ctx);
  }

  void showBackendErr(String message) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 16),

                /// 标题
                const Text(
                  "Something went wrong",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                /// 内容
                Text(
                  message,
                  style: const TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                /// 按钮
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("OK"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void showMessage(String message) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.amber,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(12),
    ).show(ctx);
  }

  String getErrorMessage(Error e) {
    if (e is AppError) {
      return e.message;
    } else if(e is BackendError){
      return e.message;
    }else{
      return "Unknow Error Please Contact Administrator";
    }
  }
}
