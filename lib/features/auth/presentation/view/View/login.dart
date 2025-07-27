import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/app/theme/colors/themecolor.dart';
import 'package:softconnect/core/utils/validators.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_event.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_state.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'forgot_password.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

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
      backgroundColor: Themecolor.white,
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
                        color: Themecolor.purple,
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
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Themecolor.lavender),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Themecolor.purple, width: 2),
                              ),
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
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Themecolor.lavender),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Themecolor.purple, width: 2),
                              ),
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
                                backgroundColor: Themecolor.purple,
                                foregroundColor: Themecolor.white,
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
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(color: Themecolor.purple),
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Themecolor.purple),
                              foregroundColor: Themecolor.purple,
                            ),
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
