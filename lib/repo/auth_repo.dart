import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/core/network.dart';

class AuthRepository {
  AuthRepository();

  Future<String?> signIn({required String email, required String password}) async {
    Map<String, dynamic> param = {"email": email, "password": password};
    InterfaceResult<String> result = await post(
      "/auth/sign-in",
      param,
      (json) => json.toString(),
    );
    if (DI.I.messageHandler.isErr(result)) {
      DI.I.messageHandler.handleErr(result);
      return null;
    } else {
      return result.value;
    }
  }

  Future<bool> signOut(String token) async {
    InterfaceResult<String> result = await post(
      "/auth/sign-out",
      {},
      (json) => json.toString(),
      token:token,
    );
    if (DI.I.messageHandler.isErr(result)) {
      DI.I.messageHandler.handleErr(result);
      return false;
    } else {
      return true;
    }
  }

  Future<InterfaceResult<String>> resetPassword(
    String email,
  ) async {
    Map<String, dynamic> param = {"email": email};
    return await post(
      '/auth/forget-password',
      param,
      (json) => json.toString(),
    );
  }

  Future<InterfaceResult<String>> confirmPassword(
    String email,
    String otp,
    String newPwd,
  ) async {
    Map<String, dynamic> param = {
      "email": email,
      "otp": otp,
      "password": newPwd,
    };

    return await post(
      '/auth/reset-password',
      param,
      (json) => json.toString(),
    );
  }
}
