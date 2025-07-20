import 'package:flutter/material.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/core/utils/mysnackbar.dart';
import 'package:softconnect/features/auth/domain/use_case/reset_password_usecase.dart';
import 'package:softconnect/features/auth/domain/use_case/verify_password.dart';

class ChangePassword extends StatefulWidget {
  final String userId;

  const ChangePassword({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _verifyController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isVerifying = false;
  bool _isResetting = false;
  bool _verified = false;

  String? _resetToken; // <-- Store token returned from verifyPassword

  final VerifyPasswordUsecase _verifyPasswordUsecase = serviceLocator<VerifyPasswordUsecase>();
  final ResetPasswordUsecase _resetPasswordUsecase = serviceLocator<ResetPasswordUsecase>();

  Future<void> _verifyCurrentPassword() async {
    final currentPassword = _verifyController.text.trim();
    if (currentPassword.isEmpty) {
      showMySnackBar(context: context, message: "Please enter your current password", color: Colors.red);
      return;
    }

    setState(() => _isVerifying = true);

    final result = await _verifyPasswordUsecase.call(
      VerifyPasswordParams(userId: widget.userId, currentPassword: currentPassword),
    );

    setState(() => _isVerifying = false);

    result.fold(
      (failure) => showMySnackBar(context: context, message: "Verification failed: ${failure.message}", color: Colors.red),
      (token) {
        _resetToken = token; // Save the token here

        showMySnackBar(context: context, message: "Password verified successfully", color: Colors.green);
        setState(() {
          _verified = true;
        });
      },
    );
  }

  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      showMySnackBar(context: context, message: "Please fill all fields", color: Colors.red);
      return;
    }
    if (newPassword != confirmPassword) {
      showMySnackBar(context: context, message: "Passwords do not match", color: Colors.red);
      return;
    }

    if (_resetToken == null) {
      showMySnackBar(context: context, message: "No valid token found for password reset", color: Colors.red);
      return;
    }

    setState(() => _isResetting = true);

    final result = await _resetPasswordUsecase.call(
      ResetPasswordParams(token: _resetToken!, newPassword: newPassword),
    );

    setState(() => _isResetting = false);

    result.fold(
      (failure) => showMySnackBar(context: context, message: "Reset failed: ${failure.message}", color: Colors.red),
      (_) {
        showMySnackBar(context: context, message: "Password reset successfully", color: Colors.green);
        Navigator.pop(context); // Go back after success
      },
    );
  }

  @override
  void dispose() {
    _verifyController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _verified ? _buildResetPasswordForm() : _buildVerifyPasswordForm(),
      ),
    );
  }

  Widget _buildVerifyPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Verify your current password", style: TextStyle(fontSize: 18)),
        const SizedBox(height: 20),
        TextField(
          controller: _verifyController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Current Password",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isVerifying ? null : _verifyCurrentPassword,
          child: _isVerifying
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text("Verify"),
        ),
      ],
    );
  }

  Widget _buildResetPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Enter your new password", style: TextStyle(fontSize: 18)),
        const SizedBox(height: 20),
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "New Password",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Confirm New Password",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isResetting ? null : _resetPassword,
          child: _isResetting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text("Reset Password"),
        ),
      ],
    );
  }
}
