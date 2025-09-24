// lib/features/auth/domain/auth_repository.dart
abstract class AuthRepository {
  /// 恢复会话（读本地 token / 视情况刷新）
  Future<bool> restoreSession();

  /// 登录（Demo 返回是否成功）
  Future<bool> signIn({required String username, required String password});

  /// 登出（清理本地会话）
  Future<void> signOut();

  /// （可选）刷新令牌，返回是否成功
  Future<bool> refreshToken();

  /// 内存态（便于快速判断）
  bool get isLoggedIn;
}
