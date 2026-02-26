
import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/core/storage/keys.dart';
import 'package:nuitri_pilot_frontend/core/storage/local_storage.dart';
import 'package:nuitri_pilot_frontend/repo/auth_repo.dart';

class AuthService{

  final String FORGET_PASSWORD = "1";
  final String SIGN_UP = "2";

  AuthRepository repo;

  AuthService(this.repo);

  Future<bool> signIn(String email, String password) async {
    String? token = await repo.signIn(email: email, password: password);
    if(token != null){
      LocalStorage().put(LOCAL_TOKEN_KEY, token);
      return true;
    }
    return false;
  }

  Future<bool> signOut() async {
    String? token = await LocalStorage().get(LOCAL_TOKEN_KEY);
    if(token == null){
        return true;
    }else{
      bool success = await repo.signOut(token);
      if(success){
        LocalStorage().del(LOCAL_TOKEN_KEY);
      }
      return success;
    }
  }

  Future<String?> requestOtp(String email, bool forget) async {
    InterfaceResult<dynamic> res =  await repo.requestOtp(email, forget? FORGET_PASSWORD: SIGN_UP);

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
    bool forget
  ) async {
    InterfaceResult<dynamic> res =  await repo.confirmPassword(email, otp, newPwd, forget ? FORGET_PASSWORD : SIGN_UP);
    if (DI.I.messageHandler.isErr(res)) {
      DI.I.messageHandler.handleErr(res);
      return null;
    } else {
      return res.value.toString();
    }
  }

  Future<bool> varifyToken() async {
    String? token = await LocalStorage().get(LOCAL_TOKEN_KEY);
    InterfaceResult<dynamic> result = await repo.varifyToken(token);
    if (DI.I.messageHandler.isErr(result)) {
      DI.I.messageHandler.handleErr(result);
      return false;
    } else {
      return true;
    }
  }
}