import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/theme/theme_provider.dart';
import 'package:softconnect/core/utils/validators.dart';
import 'package:softconnect/features/auth/presentation/view/View/google_signin_button.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_event.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_state.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  bool _isBiometricAvailable = false;
  bool _hasStoredCredentials = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _checkStoredCredentials();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = 
          await _localAuth.getAvailableBiometrics();
      
      if (mounted) {
        setState(() {
          _isBiometricAvailable = isAvailable && availableBiometrics.isNotEmpty;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBiometricAvailable = false;
        });
      }
    }
  }

  Future<void> _checkStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCredentials = prefs.containsKey('stored_username') && 
                          prefs.containsKey('stored_password');
    final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    
    if (mounted) {
      setState(() {
        _hasStoredCredentials = hasCredentials && biometricEnabled;
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to login to SoftConnect',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        await _loginWithStoredCredentials();
      }
    } catch (e) {
      _showSnackBar(context, 'Biometric authentication failed: ${e.toString()}', isError: true);
    }
  }

  Future<void> _loginWithStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('stored_username');
    final password = prefs.getString('stored_password');

    if (username != null && password != null) {
      context.read<LoginViewModel>().add(
        LoginUserEvent(
          username: username,
          password: password,
          context: context,
        ),
      );
    } else {
      _showSnackBar(context, 'No stored credentials found', isError: true);
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: BlocListener<LoginViewModel, LoginState>(
              listener: (context, state) {
                if (state.isSuccess) {
                  _showSnackBar(context, "Login Successful");
                }
                if (state.errorMessage != null) {
                  _showSnackBar(context, state.errorMessage!, isError: true);
                }
              },
              child: BlocBuilder<LoginViewModel, LoginState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "SC",
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "SoftConnect",
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    "Building Bridges at Softwarica",
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // Biometric Login Button
                            if (_isBiometricAvailable && _hasStoredCredentials) ...[
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                    foregroundColor: Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: BorderSide(color: Theme.of(context).primaryColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: state.isLoading ? null : _authenticateWithBiometrics,
                                  icon: const Icon(Icons.fingerprint, size: 24),
                                  label: const Text(
                                    'Login with Fingerprint',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'OR',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
            
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: emailController,
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(context).cardColor,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (val) => val == null || !isValidEmail(val)
                                        ? 'Enter valid email'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: passwordController,
                                    obscureText: _obscurePassword,
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(context).cardColor,
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
                                        backgroundColor: Theme.of(context).primaryColor,
                                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
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
                                          ? CircularProgressIndicator(
                                              color: Theme.of(context).colorScheme.onPrimary,
                                            )
                                          : Text(
                                              'Login',
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onPrimary,
                                              ),
                                            ),
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
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  
                                  // Divider with "OR" for Google Sign-In
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(
                                            color: Theme.of(context).textTheme.bodyMedium?.color,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Google Sign-In button
                                  const GoogleSignInButton(),
                                  
                                  const SizedBox(height: 20),
                                  
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      foregroundColor: Theme.of(context).primaryColor,
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
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}