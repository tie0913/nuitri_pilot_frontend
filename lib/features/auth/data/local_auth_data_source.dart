// lib/features/auth/data/local_auth_data_source.dart
class LocalAuthDataSource {
  String? _token; // Demo：内存保存；实际请用 flutter_secure_storage

  Future<String?> readToken() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _token;
  }

  Future<void> writeToken(String token) async {
    await Future.delayed(const Duration(milliseconds: 40));
    _token = token;
  }

  Future<void> clear() async {
    await Future.delayed(const Duration(milliseconds: 30));
    _token = null;
  }
}
