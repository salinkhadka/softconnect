import 'package:flutter/material.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/core/utils/mysnackbar.dart';
import 'package:softconnect/features/auth/domain/use_case/request_passsword_reset_usecase.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  final RequestPasswordResetUsecase _resetUsecase =
      serviceLocator<RequestPasswordResetUsecase>();

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      showMySnackBar(context: context, message: "Please enter a valid email", color: Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _resetUsecase(RequestPasswordResetParams(email: email));

    setState(() {
      _isLoading = false;
    });

    result.fold(
      (failure) => showMySnackBar(context: context, message: "Failed: ${failure.message}", color: Colors.red),
      (_) => showMySnackBar(context: context, message: "Reset link sent to $email", color: Colors.green),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Enter your registered email to receive a password reset link.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendResetLink,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Send Reset Link"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back to Login"),
            ),
          ],
        ),
      ),
    );
  }
}
