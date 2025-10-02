
import 'package:nuitri_pilot_frontend/core/error/error_handler.dart';
import 'package:nuitri_pilot_frontend/core/network.dart';
import 'package:nuitri_pilot_frontend/features/user/domain/user_repository.dart';

class UserRepositoryImpl extends UserBaseRepository{

  late final GlobalErrorHandler handler;


  @override
  Future<Result<String>> apply_for_reseting_password_otp(String email) async {
    Map<String, dynamic> param = {"email": email};
    return await post('/users/apply_for_reseting_password_otp', param, (json) => json.toString());
  }
}