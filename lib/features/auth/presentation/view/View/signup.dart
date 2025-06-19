import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/features/auth/domain/use_case/user_register_usecase.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_event.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_state.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final studentIdController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String selectedProgram = "Bsc hons computing";
  bool agreedToTerms = false;

  final List<String> programs = [
    "Bsc hons computing",
    "BIBM",
    "CSSE",
    "BIT",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<SignupViewModel, SignupState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF4B228D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: const [
                            Text("Create Your SoftConnect Account",
                                style: TextStyle(color: Colors.white, fontSize: 16)),
                            Text("Join the Softwarica student community",
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: studentIdController,
                        decoration: const InputDecoration(labelText: 'Student ID', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.isEmpty ? 'Enter student ID' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedProgram,
                        items: programs.map((program) {
                          return DropdownMenuItem<String>(
                            value: program,
                            child: Text(program),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProgram = value!;
                          });
                        },
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.length < 6 ? 'Password too short' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
                        validator: (val) => val != passwordController.text ? 'Passwords do not match' : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: agreedToTerms,
                            onChanged: (val) => setState(() => agreedToTerms = val!),
                          ),
                          const Expanded(
                            child: Text("I agree to terms and conditions of softconnect"),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isLoading || !agreedToTerms
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<SignupViewModel>().add(
                                          SignupButtonPressed(
                                            email: emailController.text.trim(),
                                            username: usernameController.text.trim(),
                                            studentId: int.parse(studentIdController.text.trim()),
                                            password: passwordController.text,
                                            role: selectedProgram,
                                            context: context,
                                          ),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4B228D),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: state.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Signup',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Already have an account?"),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
