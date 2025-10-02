

import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import '../../../core/network.dart';

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
  

  _sendOTP() async {

    setState(() {
      _loading = true;
    });
    String email = _emailControl.text;
    Result<String> res = await DI.I.userRepository.apply_for_reseting_password_otp(email);
    if(res is BizOk<String>){
      setState(() {
        step = 2;
      });
    }else{
      DI.I.errorHandler.handleBothError(res);
    }

    setState(() {
      _loading = false;
    });
  }

  _resetPassword(){

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
    TextField(controller: _otpControl, decoration: const InputDecoration(labelText: 'OTP:')),
    const SizedBox(height: 12),
    TextField(controller: _newPwdControl, decoration: const InputDecoration(labelText: 'New Password:')),
    const SizedBox(height: 12),
    TextField(controller: _confirmPwdControl, decoration: const InputDecoration(labelText: 'ConfirmPassword:')),
    const SizedBox(height: 12),
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