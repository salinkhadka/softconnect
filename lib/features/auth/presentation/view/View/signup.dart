import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:softconnect/core/utils/validators.dart'; // <-- import here
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_event.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_state.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final studentIdController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final List<String> programs = [
    "Student",
    "Teaching Assistant",
    "Marketing Department",
    "Others",
  ];

  @override
  Widget build(BuildContext context) {
    String selectedProgram = programs[0];
    final ImagePicker _picker = ImagePicker();

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<SignupViewModel, SignupState>(
        builder: (context, state) {
          if (state.message != null) {
            Future.microtask(() {
              final color = state.isSuccess ? Colors.green : Colors.red;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: color,
                ),
              );
            });
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final picked = await _picker.pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            context.read<SignupViewModel>().add(ProfilePhotoChanged(picked.path));
                          }
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: state.profilePhotoPath != null
                              ? FileImage(File(state.profilePhotoPath!))
                              : null,
                          child: state.profilePhotoPath == null ? const Icon(Icons.camera_alt) : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                        validator: (val) => val == null || !isValidEmail(val) ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: studentIdController,
                        decoration: const InputDecoration(labelText: 'Student ID', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || !isValidStudentId(val) ? 'Enter valid 6-digit student ID' : null,
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
                          if (value != null) selectedProgram = value;
                        },
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                        validator: (val) => val == null || !isValidPassword(val) ? 'Password must be at least 6 characters' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
                        validator: (val) => val == null || !doPasswordsMatch(val, passwordController.text) ? 'Passwords do not match' : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: state.agreedToTerms,
                            onChanged: (val) {
                              if (val != null) {
                                context.read<SignupViewModel>().add(AgreedToTermsToggled(val));
                              }
                            },
                          ),
                          const Expanded(
                            child: Text("I agree to terms and conditions of SoftConnect"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isLoading || !state.agreedToTerms
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<SignupViewModel>().add(
                                          SignupButtonPressed(
                                            email: emailController.text.trim(),
                                            username: usernameController.text.trim(),
                                            studentId: int.parse(studentIdController.text.trim()),
                                            password: passwordController.text.trim(),
                                            role: selectedProgram,
                                          ),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4B228D),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: state.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Signup', style: TextStyle(color: Colors.white)),
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
