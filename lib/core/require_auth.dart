// lib/core/require_auth.dart
import 'package:flutter/material.dart';
import 'di.dart';

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
  late Future<bool> _future;

  @override
  void initState() {
    super.initState();
    // 统一恢复会话 / 校验登录
    _future = DI.I.authRepo.restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.data == true) {
          return widget.builder(context);
        } else {
          // 未登录 → 重定向到 /signin
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed(widget.redirectTo);
            }
          });
          return const SizedBox.shrink();
        }
      },
    );
  }
}
