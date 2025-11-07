// lib/core/di.dart
import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/message_handler.dart';
import 'package:nuitri_pilot_frontend/page/wellness_body.dart';
import 'package:nuitri_pilot_frontend/repo/wellness_repo.dart';
import 'package:nuitri_pilot_frontend/service/auth_service.dart';
import 'package:nuitri_pilot_frontend/service/wellness_service.dart';

import '../repo/auth_repo.dart';
/*
 * 这个是组合模式依赖管理的类，使用这个类，把所有组件的构建组合放在一起
 * 这样，手动模拟了Spring中的依赖注入功能。
 *
 * 代码中关于 authRepo和localAuthDS的例子就是当对外提供用户是否登录的判定是给做了两层
 * 一层走本地，一层走网络。这样方式未来在扩展功能或修改时，在使用方看来是不变化的，因为接口签名没有变化
 * 但用这个代码来解释依赖注入有些牵强了，因为它杂糅了装饰/代理模式
 */
class DI {
  DI._();
  static final DI I = DI._();
  late final AuthService _authService;
  late final WellnessService _wellnessService;
  late final MessageHandler _messageHandler;

  /// 导航 key，便于全局错误提示/跳转
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  AuthService get authService => _authService;

  WellnessService get wellnessService => _wellnessService;

  MessageHandler get messageHandler => _messageHandler;


  /// 在应用启动时调用一次。
  void init() {
    _authService = AuthService(AuthRepository());
    _wellnessService = WellnessService(WellnessRepo());
    _messageHandler = GlobalMessageHandler(
      navigatorKey: navigatorKey,
      messengerKey: scaffoldMessengerKey,
    );
  }
}
