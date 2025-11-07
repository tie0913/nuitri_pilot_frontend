// lib/core/require_auth.dart
import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/storage/keys.dart';
import 'package:nuitri_pilot_frontend/core/storage/local_storage.dart';

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

  @override
  void initState() {
    super.initState();
  }

  Future<bool> hasSignedIn() async {
    return LocalStorage().containsKey(LOCAL_TOKEN_KEY);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: hasSignedIn(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        /**
         * 这里留一个口子，现在不管谁来都直接返回给需要的页面
         * 未来这里要根据条件判断用户是否登录
         */

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
