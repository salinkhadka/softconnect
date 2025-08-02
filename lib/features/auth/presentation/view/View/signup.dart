import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:softconnect/app/theme/colors/themecolor.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: BlocBuilder<SignupViewModel, SignupState>(
          builder: (context, state) {
            if (state.message != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final color = state.isSuccess 
                    ? theme.primaryColor 
                    : theme.colorScheme.error;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message!,
                      style: TextStyle(
                        color: theme.colorScheme.onError,
                      ),
                    ),
                    backgroundColor: color,
                  ),
                );
                // Clear message after showing
                context.read<SignupViewModel>().add(ClearMessage());
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
                        // Enhanced Profile Image Container
                        GestureDetector(
                          onTap: () => _showImageSourcePicker(context),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow effect
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primaryColor.withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                // Main avatar container
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: state.profilePhotoPath != null 
                                        ? null 
                                        : LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              theme.primaryColor.withOpacity(0.1),
                                              theme.primaryColor.withOpacity(0.05),
                                            ],
                                          ),
                                    border: Border.all(
                                      color: theme.primaryColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: state.profilePhotoPath != null
                                        ? Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.file(
                                                File(state.profilePhotoPath!),
                                                fit: BoxFit.cover,
                                              ),
                                              // Overlay for edit hint
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black.withOpacity(0.3),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              gradient: RadialGradient(
                                                colors: [
                                                  theme.primaryColor.withOpacity(0.1),
                                                  theme.primaryColor.withOpacity(0.05),
                                                ],
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.person_add_alt_1,
                                              color: theme.primaryColor,
                                              size: 32,
                                            ),
                                          ),
                                  ),
                                ),
                                // Camera icon overlay
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.scaffoldBackgroundColor,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: theme.colorScheme.onPrimary,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Helper text
                        Text(
                          state.profilePhotoPath != null ? 'Tap to change photo' : 'Tap to add photo',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          context: context,
                          controller: usernameController,
                          labelText: 'Username',
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Enter name' : null,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          context: context,
                          controller: emailController,
                          labelText: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) => val == null || !isValidEmail(val)
                              ? 'Enter a valid email'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          context: context,
                          controller: studentIdController,
                          labelText: 'Student ID',
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || !isValidStudentId(val)
                              ? 'Enter valid 6-digit student ID'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: state.selectedProgram ?? programs[0],
                          items: programs.map((program) {
                            return DropdownMenuItem<String>(
                              value: program,
                              child: Text(
                                program,
                                style: TextStyle(color: theme.colorScheme.onSurface),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              context.read<SignupViewModel>().add(ProgramChanged(value));
                            }
                          },
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          dropdownColor: theme.colorScheme.surface,
                          decoration: InputDecoration(
                            labelText: 'Role',
                            labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.primaryColor, 
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          context: context,
                          controller: passwordController,
                          labelText: 'Password',
                          obscureText: state.obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            onPressed: () {
                              context.read<SignupViewModel>().add(PasswordVisibilityToggled());
                            },
                          ),
                          validator: (val) => val == null || !isValidPassword(val)
                              ? 'Password must be at least 6 characters'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          context: context,
                          controller: confirmPasswordController,
                          labelText: 'Confirm Password',
                          obscureText: state.obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            onPressed: () {
                              context.read<SignupViewModel>().add(ConfirmPasswordVisibilityToggled());
                            },
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
                              activeColor: theme.primaryColor,
                              checkColor: theme.colorScheme.onPrimary,
                              onChanged: (val) {
                                if (val != null) {
                                  context
                                      .read<SignupViewModel>()
                                      .add(AgreedToTermsToggled(val));
                                }
                              },
                            ),
                            Expanded(
                              child: Text(
                                "I agree to terms and conditions of SoftConnect",
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                ),
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
                                              email: emailController.text.trim(),
                                              username: usernameController.text.trim(),
                                              studentId: int.parse(
                                                  studentIdController.text.trim()),
                                              password: passwordController.text.trim(),
                                              role: state.selectedProgram ?? programs[0],
                                            ),
                                          );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: theme.colorScheme.onPrimary,
                              disabledBackgroundColor: theme.colorScheme.outline,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: state.isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : Text(
                                    'Signup',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: theme.primaryColor,
                          ),
                          child: Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      validator: validator,
    );
  }

  void _showImageSourcePicker(BuildContext context) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: theme.primaryColor),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: theme.primaryColor),
              title: Text(
                'Take a Photo',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
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
    final theme = Theme.of(context);

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
        SnackBar(
          content: const Text('Permission denied. Please allow it to continue.'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permission permanently denied. Open app settings to enable it.'),
          backgroundColor: theme.colorScheme.error,
          action: SnackBarAction(
            label: 'Settings',
            textColor: theme.colorScheme.onError,
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }
}