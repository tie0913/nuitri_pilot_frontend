import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/widgets/text_field_widget.dart';
import '../core/di.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;

  Future<void> _submit() async {
    setState(() { _loading = true;});
    bool success = await DI.I.authService.signIn(_userCtrl.text.trim(), _passCtrl.text);
    setState(() => _loading = false);
    if(success){
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    }
  }

  void _gotoForgetPassword() {
    Navigator.pushNamedAndRemoveUntil(context, '/forgetPassword', (r) => false);
  }

  void _gotoSignUp(){}

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Nutri Pilot')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Fuel Smart, Live Better",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              AppTextField(controller: _userCtrl, label: "Email"),
              const SizedBox(height: 12),
              AppPasswordField(controller: _passCtrl, label: "Password"),
              const SizedBox(height: 20),

              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Sign In'),
              ),
              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: _loading ? null : _gotoSignUp,
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 10),

              TextButton(
                onPressed: _loading ? null : _gotoForgetPassword,
                child: const Text(
                  "Forgot password?",
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutri Pilot')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: _userCtrl, label: "Email",),
            AppPasswordField(controller: _passCtrl, label: "Password"),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Sign In'),
            ),
            FilledButton(
              onPressed: _loading ? null: _gotoForgetPassword ,
              child: _loading  
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Forget Password'),
            ),
          ],
        ),
      ),
    );
  }*/
}
