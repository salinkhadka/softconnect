import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/theme/colors/themecolor.dart';
import 'package:softconnect/core/utils/validators.dart';
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
  bool _biometricEnabled = false;

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
        _biometricEnabled = biometricEnabled;
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

  Future<void> _saveCredentialsForBiometric(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stored_username', username);
    await prefs.setString('stored_password', password);
    await prefs.setBool('biometric_enabled', true);
  }

  void _showBiometricSetupDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Biometric Login'),
          content: const Text(
            'Would you like to enable fingerprint/face unlock for faster login in the future?'
          ),
          actions: [
            TextButton(
              child: const Text('Skip'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _saveCredentialsForBiometric(
                  emailController.text.trim(),
                  passwordController.text,
                );
                if (mounted) {
                  _showSnackBar(context, 'Biometric login enabled!');
                  setState(() {
                    _hasStoredCredentials = true;
                    _biometricEnabled = true;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

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
      body: BlocListener<LoginViewModel, LoginState>(
        listener: (context, state) {
          if (state.isSuccess) {
            _showSnackBar(context, "Login Successful");
            // Show biometric setup dialog if:
            // 1. Biometrics are available
            // 2. User logged in via form (not biometric)
            // 3. Either no biometric is enabled OR credentials were entered manually
            // 4. Widget is still mounted
            if (_isBiometricAvailable && 
                emailController.text.isNotEmpty && // Form was used
                mounted) {
              
              // Check if biometric should be offered
              _checkIfShouldOfferBiometric();
            }
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
                          color: Themecolor.purple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          children: [
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
                      
                      // Biometric Login Button
                      if (_isBiometricAvailable && _hasStoredCredentials) ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Themecolor.purple.withOpacity(0.1),
                              foregroundColor: Themecolor.purple,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Themecolor.purple),
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
                        
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OR', style: TextStyle(color: Colors.grey)),
                            ),
                            Expanded(child: Divider()),
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
                            
                            // Biometric settings option
                            if (_isBiometricAvailable && _hasStoredCredentials) ...[
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: () => _showBiometricSettingsDialog(),
                                icon: const Icon(Icons.settings, size: 16),
                                label: const Text('Biometric Settings'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey[600],
                                ),
                              ),
                            ],
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
    );
  }

  Future<void> _checkIfShouldOfferBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    
    // Offer biometric setup if it's not currently enabled
    if (!biometricEnabled) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showBiometricSetupDialog();
        }
      });
    }
  }

  void _showBiometricSettingsDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Biometric Settings'),
          content: const Text('Do you want to disable biometric login?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Disable'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('stored_username');
                await prefs.remove('stored_password');
                await prefs.setBool('biometric_enabled', false);
                
                if (mounted) {
                  setState(() {
                    _hasStoredCredentials = false;
                    _biometricEnabled = false;
                  });
                  
                  Navigator.of(context).pop();
                  _showSnackBar(context, 'Biometric login disabled');
                }
              },
            ),
          ],
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