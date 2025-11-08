import 'dart:convert';
import 'dart:typed_data';

import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/core/storage/keys.dart';
import 'package:nuitri_pilot_frontend/core/storage/local_storage.dart';
import 'package:nuitri_pilot_frontend/repo/auth_repo.dart';

class AuthService{

  AuthRepository repo;

  AuthService(this.repo);

  Future<bool> signIn(String email, String password) async {
    String? token = await repo.signIn(email: email, password: password);
    if(token != null){
      Uint8List value = Uint8List.fromList(utf8.encode(token));
      LocalStorage().put(LOCAL_TOKEN_KEY, value);
      return true;
    }
    return false;
  }

  Future<bool> signOut() async {
    Uint8List? value = LocalStorage().get(LOCAL_TOKEN_KEY);
    String token = utf8.decode(Uint8List.fromList(value!));
    bool success = await repo.signOut(token);
    if(success){
      LocalStorage().del(LOCAL_TOKEN_KEY);
    }
    return success;
  }

  Future<String?> resetPassword(String email) async {
    InterfaceResult<dynamic> res =  await repo.resetPassword(email);

    if (DI.I.messageHandler.isErr(res)) {
      DI.I.messageHandler.handleErr(res);
      return null;
    } else {
      return res.value.toString();
    }
  }

  Future<String?> confirmPassword(
    String email,
    String otp,
    String newPwd,
  ) async {
    InterfaceResult<dynamic> res =  await repo.confirmPassword(email, otp, newPwd);
    if (DI.I.messageHandler.isErr(res)) {
      DI.I.messageHandler.handleErr(res);
      return null;
    } else {
      return res.value.toString();
    }
  }

}