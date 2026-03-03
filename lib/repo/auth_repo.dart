import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/network.dart';

class AuthRepository {
  AuthRepository();

  Future<Result<Error, String?>> signIn({required String email, required String password}) async {
    Map<String, dynamic> param = {"email": email, "password": password};
    return await post(
      "/auth/sign-in",
      param,
      decoder: (json) => json,
    );
  }

  Future<Result<Error, bool>> signOut(String token) async {
    return await post(
      "/auth/sign-out",
      {},
      token:token,
      decoder: (json) => json
    );
  }

  Future<Result<Error, String?>> requestOtp(
    String email, String bizId 
  ) async {
    return await post(
      '/auth/request-otp',
      {"email": email, "biz_id": bizId},
      decoder: (json) => json
    );
  }

  Future<Result<Error, String?>> confirmPassword(
    String email,
    String otp,
    String newPwd,
    String bizId
  ) async {
    Map<String, dynamic> param = {
      "email": email,
      "otp": otp,
      "password": newPwd,
      "biz_id": bizId
    };

    return await post(
      '/auth/confirm-password',
      param,
      decoder: (json) => json
    );
  }

  Future<Result<Error, bool>> varifyToken(String? token) async {
      return await post('/auth/me', {}, token:token, decoder: (json) => json);
  }
}
