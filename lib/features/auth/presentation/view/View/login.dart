import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/core/utils/validators.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_event.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_state.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'forgot_password.dart';  // Import ForgotPassword page

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key}); // Added key for best practice

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<LoginViewModel, LoginState>(
        builder: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (state.isSuccess) {
              _showSnackBar(context, "Login Successful");
            }
            if (state.errorMessage != null) {
              _showSnackBar(context, state.errorMessage!, isError: true);
            }
          });

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4B228D),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: const [
                          Text(
                            "SC",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "SoftConnect",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            "Building Bridges at Softwarica",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => val == null || !isValidEmail(val)
                                ? 'Enter valid email'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Enter Password'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4B228D),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<LoginViewModel>().add(
                                              LoginUserEvent(
                                                username: emailController.text.trim(),
                                                password: passwordController.text,
                                                context: context,
                                              ),
                                            );
                                      }
                                    },
                              child: state.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Login', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPassword(),
                                ),
                              );
                            },
                            child: const Text("Forgot password?"),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () {
                              context.read<LoginViewModel>().add(
                                    NavigateToSignUpEvent(context: context),
                                  );
                            },
                            child: const Text("Create an account"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
