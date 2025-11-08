import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/core/network.dart';

class AuthRepository {
  AuthRepository();

  Future<String?> signIn({required String email, required String password}) async {
    Map<String, dynamic> param = {"email": email, "password": password};
    InterfaceResult<dynamic> result = await post(
      "/auth/sign-in",
      param,
    );
    if (DI.I.messageHandler.isErr(result)) {
      DI.I.messageHandler.handleErr(result);
      return null;
    } else {
      return result.value.toString();
    }
  }

  Future<bool> signOut(String token) async {
    InterfaceResult<dynamic> result = await post(
      "/auth/sign-out",
      {},
      token:token,
    );
    if (DI.I.messageHandler.isErr(result)) {
      DI.I.messageHandler.handleErr(result);
      return false;
    } else {
      return true;
    }
  }

  Future<InterfaceResult<dynamic>> resetPassword(
    String email,
  ) async {
    return await post(
      '/auth/forget-password',
      {"email": email}
    );
  }

  Future<InterfaceResult<dynamic>> confirmPassword(
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
      param
    );
  }
}
