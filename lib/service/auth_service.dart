
import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/storage/keys.dart';
import 'package:nuitri_pilot_frontend/core/storage/local_storage.dart';
import 'package:nuitri_pilot_frontend/repo/auth_repo.dart';

class AuthService{

  final String FORGET_PASSWORD = "1";
  final String SIGN_UP = "2";

  AuthRepository repo;

  AuthService(this.repo);

  Future<Result<Error, bool>> signIn(String email, String password) async {
    Result<Error, String?> res = await repo.signIn(email: email, password: password);
    if(res is OK){
      LocalStorage().put(LOCAL_TOKEN_KEY, (res as OK).value);
      return OK(true);
    }else{
      return Err<BackendError, bool>((res as Err).error);
    }
  }

  Future<Result<Error, bool>> signOut() async {
    String? token = await LocalStorage().get(LOCAL_TOKEN_KEY);
    return await repo.signOut(token!);
  }

  Future<Result<Error, String?>> requestOtp(String email, bool forget) async {
    return await repo.requestOtp(email, forget? FORGET_PASSWORD: SIGN_UP);
  }

  Future<Result<Error, String?>> confirmPassword(
    String email,
    String otp,
    String newPwd,
    bool forget
  ) async {
    return await repo.confirmPassword(email, otp, newPwd, forget ? FORGET_PASSWORD : SIGN_UP);
  }

  Future<Result<Error, bool>> varifyToken() async {
    String? token = await LocalStorage().get(LOCAL_TOKEN_KEY);
    return await repo.varifyToken(token);
  }
}