// lib/core/require_auth.dart
import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';

/// 给需要保护的页面外面包一层 RequireAuth。
/// 进入时统一执行鉴权（异步），未通过则跳 /signin。
class RequireAuth extends StatefulWidget {
  const RequireAuth({
    super.key,
    required this.builder,
    this.redirectTo = '/signin',
  });

  final WidgetBuilder builder;
  final String redirectTo;

  @override
  State<RequireAuth> createState() => _RequireAuthState();
}

class _RequireAuthState extends State<RequireAuth> {
  late Future<Result<Error, bool>> _future;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _future = DI.I.authService.varifyToken();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<Error, bool>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final result = snap.data;

        // 防止重复执行副作用
        if (!_handled) {
          _handled = true;

          if (result is Err) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              DI.I.messageHandler.doIfErr(result!);
              Navigator.of(context)
                  .pushReplacementNamed(widget.redirectTo);
            });
          } else if (result is OK<Error, bool>) {
            if (!result.value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                Navigator.of(context)
                    .pushReplacementNamed(widget.redirectTo);
              });
            }
          }
        }

        // 如果成功登录
        if (result is OK<Error, bool> && result.value == true) {
          return widget.builder(context);
        }

        return const SizedBox.shrink();
      },
    );
  }
}