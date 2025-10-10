import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/core/network.dart';

import '../domain/auth_repository.dart';
import 'local_auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._local);
  final LocalAuthDataSource _local;

  bool _isLoggedIn = false;
  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  Future<bool> restoreSession() async {
    final token = await _local.readToken();
    _isLoggedIn = token != null && token.isNotEmpty;
    return _isLoggedIn;
  }

  @override
  Future<bool> signIn({required String email, required String password}) async {
    Map<String, dynamic> param = {"email": email, "password": password};
    InterfaceResult<String> result =  await post("/auth/signin", param, (json) => json.toString());
    if(DI.I.messageHandler.isErr(result)){
      DI.I.messageHandler.handleErr(result);
      _isLoggedIn = false;
    }else{
      await _local.writeToken('demo_token_${DateTime.now().millisecondsSinceEpoch}');
      _isLoggedIn = true;
    }
    return _isLoggedIn;

  }

  @override
  Future<bool> signOut() async {
    String? token = await _local.readToken();
    Map<String, dynamic> param = {"token": token!};
    InterfaceResult<String> result = await post("/auth/signout", param, (json)=> json.toString());
    if(DI.I.messageHandler.isErr(result)){
      DI.I.messageHandler.handleErr(result);
      return false;
    }else{
      await _local.clear();
      _isLoggedIn = false;
      return true;
    }
  }

  @override
  Future<bool> refreshToken() async {
    // Demo：不做真正刷新；实际应调 /auth/refresh
    // 刷新失败时应清理并返回 false
    await Future.delayed(const Duration(milliseconds: 60));
    return isLoggedIn; // 假装刷新成功（仅示例）
  }
}