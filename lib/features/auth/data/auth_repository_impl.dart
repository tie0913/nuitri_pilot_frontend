// lib/features/auth/data/auth_repository_impl.dart
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
  Future<bool> signIn({required String username, required String password}) async {
    // Demo：只要非空就当登录成功；实际应调后端 API。
    final ok = username.isNotEmpty && password.isNotEmpty;
    if (ok) {
      await _local.writeToken('demo_token_${DateTime.now().millisecondsSinceEpoch}');
      _isLoggedIn = true;
    }
    return ok;
  }

  @override
  Future<void> signOut() async {
    await _local.clear();
    _isLoggedIn = false;
  }

  @override
  Future<bool> refreshToken() async {
    // Demo：不做真正刷新；实际应调 /auth/refresh
    // 刷新失败时应清理并返回 false
    await Future.delayed(const Duration(milliseconds: 60));
    return isLoggedIn; // 假装刷新成功（仅示例）
  }
}
