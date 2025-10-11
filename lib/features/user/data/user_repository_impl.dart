import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/message_handler.dart';
import 'package:nuitri_pilot_frontend/core/network.dart';
import 'package:nuitri_pilot_frontend/features/user/domain/user_repository.dart';

class UserRepositoryImpl extends UserBaseRepository {
  late final GlobalMessageHandler handler;

  @override
  Future<InterfaceResult<String>> applyForResetingPasswordOtp(
    String email,
  ) async {
    Map<String, dynamic> param = {"email": email};
    return await post(
      '/auth/forget-password',
      param,
      (json) => json.toString(),
    );
  }

  @override
  Future<InterfaceResult<String>> confirmOtpAndResetPassword(
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
