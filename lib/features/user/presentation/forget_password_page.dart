

import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/core/widgets/text_field_widget.dart';
import '../../../core/network.dart';
import 'package:email_validator/email_validator.dart';

class ForgetPasswordPage extends StatefulWidget{

  const ForgetPasswordPage({super.key});

  @override
  State<StatefulWidget> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPasswordPage>{

  String? _error;
  int step = 1;
  bool _loading = false;
  final _emailControl = TextEditingController();
  final _otpControl = TextEditingController();
  final _newPwdControl = TextEditingController();
  final _confirmPwdControl = TextEditingController();

  bool _validateEmail(String email) => EmailValidator.validate(email);
  

  _sendOTP() async {

    setState(() {
      _loading = true;
    });

    String email = _emailControl.text;

    if(_validateEmail(email)){  
      Result<String> res = await DI.I.userRepository.applyForResetingPasswordOtp(email);
      if(res is BizOk<String>){
        setState(() {
          step = 2;
        });
      }else{
        DI.I.errorHandler.handleBothError(res);
      }
    }else{
      DI.I.errorHandler.handleBothError(BizErr(1, "Email is not valid"));
    }
    setState(() {
      _loading = false;
    });
  }

  _resetPassword(){
    String email = _emailControl.text;
    String otp = _otpControl.text;
    String newPwd = _newPwdControl.text;
    String confirmPwd = _confirmPwdControl.text;

    

  }

  List<Widget> get step1Controls=> [
    TextField(controller: _emailControl, decoration: const InputDecoration(labelText: 'Email:')),
    const SizedBox(height: 12),
    if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
    FilledButton(
      onPressed: _loading ? null : _sendOTP,
      child: _loading
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Text('Get OTP'),
    )
  ];

  List<Widget> get step2Controls => [
    AppTextField(controller: _otpControl, label: "OTP"),
    AppPasswordField(controller: _newPwdControl, label:"New Password"),
    AppPasswordField(controller: _confirmPwdControl, label:"Confirm Password"),
    FilledButton(
      onPressed: _loading ? null : _resetPassword,
      child: _loading
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Text('Reset Password'),
    ),
  ];

  List<Widget> _getWidgets(v){
    if(v == 1){
      return step1Controls;
    }else{
      return step2Controls;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(title: const Text('Forget Password')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _getWidgets(step)
            ),
          ),
        );
  }
  
}