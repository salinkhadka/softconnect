import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:softconnect/core/utils/validators.dart';
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
                        onTap: () => _showImageSourcePicker(context),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: state.profilePhotoPath != null
                              ? FileImage(File(state.profilePhotoPath!))
                              : null,
                          child: state.profilePhotoPath == null
                              ? const Icon(Icons.camera_alt)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || !isValidEmail(val)
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: studentIdController,
                        decoration: const InputDecoration(
                          labelText: 'Student ID',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || !isValidStudentId(val)
                            ? 'Enter valid 6-digit student ID'
                            : null,
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
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || !isValidPassword(val)
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null ||
                                !doPasswordsMatch(
                                    val, passwordController.text)
                            ? 'Passwords do not match'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: state.agreedToTerms,
                            onChanged: (val) {
                              if (val != null) {
                                context
                                    .read<SignupViewModel>()
                                    .add(AgreedToTermsToggled(val));
                              }
                            },
                          ),
                          const Expanded(
                            child: Text(
                              "I agree to terms and conditions of SoftConnect",
                            ),
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
                                            email:
                                                emailController.text.trim(),
                                            username:
                                                usernameController.text.trim(),
                                            studentId: int.parse(
                                                studentIdController.text
                                                    .trim()),
                                            password:
                                                passwordController.text.trim(),
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
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Signup',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Already have an account?"),
                      ),
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

  void _showImageSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
  final picker = ImagePicker();

  Permission permission;

  if (source == ImageSource.camera) {
    permission = Permission.camera;
  } else {
    if (Platform.isAndroid && Platform.version.startsWith('13')) {
      permission = Permission.photos;
    } else if (Platform.isAndroid) {
      permission = Permission.storage;
    } else {
      permission = Permission.photos; // iOS
    }
  }

  // Request permission
  PermissionStatus status = await permission.request();

  if (status.isGranted) {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      context.read<SignupViewModel>().add(ProfilePhotoChanged(pickedFile.path));
    }
  } else if (status.isDenied) {
    // Show permission dialog again
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permission denied. Please allow it to continue.')),
    );
  } else if (status.isPermanentlyDenied) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Permission permanently denied. Open app settings to enable it.'),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }
}


}
