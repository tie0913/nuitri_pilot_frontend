import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/core/string_extension.dart';
import 'package:nuitri_pilot_frontend/core/widgets/text_field_widget.dart';
import 'package:email_validator/email_validator.dart';

class ForgetPasswordPage extends StatefulWidget {

  final bool forget;
  const ForgetPasswordPage({super.key, required this.forget});

  @override
  State<StatefulWidget> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPasswordPage> {

  String? _error;
  int step = 1;
  bool _loading = false;
  final _emailControl = TextEditingController();
  final _otpControl = TextEditingController();
  final _newPwdControl = TextEditingController();
  final _confirmPwdControl = TextEditingController();
  

  AppResult<String> _validateEmail(String email) {
    
    if (EmailValidator.validate(email)) {
      return AppOk(email);
    } else {
      return AppErr(message: "Email is illegal");
    }
  }

  AppResult<Map<String, dynamic>> _validateReset(
    String otp,
    String newPwd,
    String confirmPwd,
  ) {
    if (otp.isNullOrBlankOrEmpty) {
      return AppErr(message: "OTP can not be empty");
    } else if (newPwd.isNullOrBlankOrEmpty) {
      return AppErr(message: "New Password can bot be empty");
    } else if (confirmPwd.isNullOrBlankOrEmpty) {
      return AppErr(message: "Confirm Password can not be empty");
    } else if (newPwd != confirmPwd) {
      return AppErr(message: "New Password must equal to Confirm Password");
    } else {
      return AppOk(<String, dynamic>{
        "otp": otp,
        "newPwd": newPwd,
        "confirmPwd": confirmPwd,
      });
    }
  }

  _sendOTP() async {
    setState(() {
      _loading = true;
    });

    String email = _emailControl.text;
    AppResult<String> validatingResult = _validateEmail(email);
    if (DI.I.messageHandler.isErr(validatingResult)) {
      DI.I.messageHandler.handleErr(validatingResult);
    } else {
      String? res = await DI.I.authService.requestOtp(email, widget.forget);
      if (res != null) {
        setState(() {
          step = 2;
        });
      }
    }
    setState(() {
      _loading = false;
    });
  }

  _resetPassword() async {
    String email = _emailControl.text;
    String otp = _otpControl.text;
    String newPwd = _newPwdControl.text;
    String confirmPwd = _confirmPwdControl.text;

    AppResult<Map<String, dynamic>> validateRes = _validateReset(
      otp,
      newPwd,
      confirmPwd,
    );
    if (DI.I.messageHandler.isErr(validateRes)) {
      DI.I.messageHandler.handleErr(validateRes);
    } else {
      String? res = await DI.I.authService.confirmPassword(email, otp, newPwd, widget.forget);
      if (res != null) {
        DI.I.messageHandler.showMessage(res);
        Navigator.pushNamedAndRemoveUntil(context, '/signin', (r) => false);
      }
    }
  }


  List<Widget> get step1Controls => [
     Text(
      widget.forget ? "Forgot your password?" : "Welcome to Nutri Pilot",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 8),
    const Text(
      "Enter your email and we'll send you a one-time code.",
      textAlign: TextAlign.center,
    ),
    const SizedBox(height: 24),

    // 这里可以继续用 TextField，也可以换成 AppTextField
    TextField(
      controller: _emailControl,
      decoration: const InputDecoration(labelText: 'Email'),
      keyboardType: TextInputType.emailAddress,
    ),

    const SizedBox(height: 12),
    if (_error != null)
      Text(_error!, style: const TextStyle(color: Colors.red)),
    const SizedBox(height: 20),

    FilledButton(
      onPressed: _loading ? null : _sendOTP,
      child: _loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Get OTP'),
    ),
    const SizedBox(height: 12),

    //返回登录按钮（步骤 1）
    TextButton(
      onPressed: _loading
          ? null
          : () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/signin',
                (r) => false,
              );
            },
      child: const Text("Back to Sign In"),
    ),
  ];

  List<Widget> get step2Controls => [
    Text(
      widget.forget ? "Reset your password?" : "Create your account",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 8),
    const Text(
      "Enter the OTP and your new password.",
      textAlign: TextAlign.center,
    ),
    const SizedBox(height: 24),

    AppTextField(controller: _otpControl, label: "OTP"),
    const SizedBox(height: 12),
    AppPasswordField(controller: _newPwdControl, label: "New Password"),
    const SizedBox(height: 12),
    AppPasswordField(controller: _confirmPwdControl, label: "Confirm Password"),
    const SizedBox(height: 20),

    FilledButton(
      onPressed: _loading ? null : _resetPassword,
      child: _loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(widget.forget? 'Reset Password' : 'Create Account'),
    ),
    const SizedBox(height: 12),

    // 返回登录按钮（步骤 2）
    TextButton(
      onPressed: _loading
          ? null
          : () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/signin',
                (r) => false,
              );
            },
      child: const Text("Back to Sign In"),
    ),
  ];

  List<Widget> _getWidgets(v) {
    if (v == 1) {
      return step1Controls;
    } else {
      return step2Controls;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutri Pilot')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _getWidgets(step),
            ),
          ),
        ),
      ),
    );
  }
}
