import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/widgets/text_field_widget.dart';
import '../../../core/di.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {


  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;


  String? _error;

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final ok = await DI.I.authRepo.signIn(
      username: _userCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    } else {
      setState(() => _error = 'Invalid credentials');
    }
  }

  void _gotoForgetPassword() {
    Navigator.pushNamedAndRemoveUntil(context, '/forgetPassword', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: _userCtrl, label: "Email",),
            
            AppPasswordField(controller: _passCtrl, label: "Password"),
            
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
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
  }
}
