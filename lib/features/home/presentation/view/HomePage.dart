import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/app/theme/colors/themecolor.dart';
import 'package:softconnect/features/home/domain/use_case/getPostsUseCase.dart';
import 'package:softconnect/features/home/presentation/view/CreatePostModal.dart';
import 'package:softconnect/features/home/presentation/view/user_search_delegate.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_event.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/home_state.dart';
import 'package:softconnect/features/home/presentation/view_model/homepage_viewmodel.dart';
import 'package:softconnect/features/notification/presentation/view/notification_page.dart';
import 'package:softconnect/features/notification/presentation/view_model/notification_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StreamSubscription _accelerometerSubscription;
  double _shakeThreshold = 15.0;
  DateTime? _lastShakeTime;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _startListeningToShake();
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    super.dispose();
  }

  void _startListeningToShake() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      double acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (acceleration > _shakeThreshold) {
        final now = DateTime.now();
        if (_lastShakeTime == null || now.difference(_lastShakeTime!) > const Duration(seconds: 2)) {
          _lastShakeTime = now;
          _onShakeDetected();
        }
      }
    });
  }

  void _onShakeDetected() {
    final homeViewModel = context.read<HomeViewModel>();
    homeViewModel.logout(context);
  }

  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  void _showPostModal(BuildContext context) async {
    final userId = await _getCurrentUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final createPostUsecase = serviceLocator<CreatePostUsecase>();
    final uploadImageUsecase = serviceLocator<UploadImageUsecase>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return CreatePostModal(
          createPostUsecase: createPostUsecase,
          uploadImageUsecase: uploadImageUsecase,
          userId: userId,
        );
      },
    );

    if (result == true && context.mounted) {
      final feedViewModel = BlocProvider.of<FeedViewModel>(context, listen: false);
      feedViewModel.add(LoadPostsEvent(userId));
    }
  }

  void _openUserSearch(BuildContext context) {
    showSearch(context: context, delegate: UserSearchDelegate());
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => serviceLocator<NotificationViewModel>(),
          child: const NotificationPage(),
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    final homeViewModel = context.read<HomeViewModel>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SettingsBottomSheet(
          localAuth: _localAuth,
          homeViewModel: homeViewModel,
        );
      },
    );
  }
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<HomeViewModel>(),
      child: BlocBuilder<HomeViewModel, HomeState>(
        builder: (context, state) {
          if (state.views.isEmpty) {
            return Scaffold(
              backgroundColor: Themecolor.white,
              body: SafeArea(
                child: Center(
                  child: CircularProgressIndicator(color: Themecolor.purple),
                ),
              ),
            );
          }

          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Themecolor.white,
            appBar: AppBar(
              title: const Text('SoftConnect'),
              backgroundColor: Themecolor.purple,
              foregroundColor: Themecolor.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _openUserSearch(context),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () => _openNotifications(context),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => _showSettingsBottomSheet(context),
                ),
              ],
            ),
            body: SafeArea(
              child: state.views[state.selectedIndex],
            ),
            bottomNavigationBar: SafeArea(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  BottomNavigationBar(
                    currentIndex: state.selectedIndex,
                    onTap: (index) =>
                        context.read<HomeViewModel>().onTabTapped(index),
                    selectedItemColor: Themecolor.purple,
                    unselectedItemColor: Themecolor.lavender,
                    backgroundColor: Themecolor.white,
                    items: const [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.group), label: 'Friends'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.message), label: 'Messages'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.person), label: 'Profile'),
                    ],
                    type: BottomNavigationBarType.fixed,
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FloatingActionButton(
                        onPressed: () => _showPostModal(context),
                        backgroundColor: Themecolor.purple,
                        foregroundColor: Themecolor.white,
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SettingsBottomSheet extends StatefulWidget {
  final LocalAuthentication localAuth;
  final HomeViewModel homeViewModel;

  const SettingsBottomSheet({
    super.key, 
    required this.localAuth,
    required this.homeViewModel,
  });

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  bool _isBiometricAvailable = false;
  bool _hasBiometricEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    try {
      final bool isAvailable = await widget.localAuth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = 
          await widget.localAuth.getAvailableBiometrics();
      
      final prefs = await SharedPreferences.getInstance();
      final hasEnabled = prefs.getBool('biometric_enabled') ?? false;
      
      if (mounted) {
        setState(() {
          _isBiometricAvailable = isAvailable && availableBiometrics.isNotEmpty;
          _hasBiometricEnabled = hasEnabled;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBiometricAvailable = false;
          _hasBiometricEnabled = false;
        });
      }
    }
  }

  Future<void> _toggleBiometric() async {
    if (!_isBiometricAvailable) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_hasBiometricEnabled) {
        // Show confirmation dialog before disabling
        _showDisableBiometricDialog();
      } else {
        // Enable biometric authentication
        await _enableBiometric();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to toggle biometric setting', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _enableBiometric() async {
    try {
      // First authenticate with biometrics to verify it works
      final bool isAuthenticated = await widget.localAuth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!isAuthenticated) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('Authentication failed', isError: true);
        }
        return;
      }

      // Show dialog to get user credentials for storage
      await _showCredentialsDialog();

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Biometric authentication failed: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _showCredentialsDialog() async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Biometric Login'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please enter your login credentials to enable biometric authentication:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter your email'
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
                      ? 'Please enter your password'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Save & Enable'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _saveCredentialsAndEnable(
        emailController.text.trim(),
        passwordController.text,
      );
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> _saveCredentialsAndEnable(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('stored_username', email);
      await prefs.setString('stored_password', password);
      await prefs.setBool('biometric_enabled', true);
      
      if (mounted) {
        setState(() {
          _hasBiometricEnabled = true;
          _isLoading = false;
        });
        _showSnackBar('Biometric login enabled successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Failed to enable biometric login', isError: true);
      }
    }
  }

  void _showDisableBiometricDialog() async {
    final shouldDisable = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disable Biometric Login'),
          content: const Text('Are you sure you want to disable biometric login? You will need to use your password to login in the future.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                'Disable',
                style: TextStyle(color: Colors.red[600]),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDisable == true) {
      await _disableBiometric();
    } else {
      // Reset loading state if user cancelled
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _disableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('stored_username');
      await prefs.remove('stored_password');
      await prefs.setBool('biometric_enabled', false);
      
      if (mounted) {
        setState(() {
          _hasBiometricEnabled = false;
          _isLoading = false;
        });
        _showSnackBar('Biometric login disabled');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Failed to disable biometric login', isError: true);
      }
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.red[600]),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close bottom sheet
                widget.homeViewModel.logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Biometric Settings
          if (_isBiometricAvailable) ...[
            ListTile(
              leading: Icon(
                Icons.fingerprint,
                color: Themecolor.purple,
                size: 28,
              ),
              title: const Text('Biometric Login'),
              subtitle: Text(
                _hasBiometricEnabled 
                  ? 'Enabled - Use fingerprint to login' 
                  : 'Disabled - Tap to enable biometric login'
              ),
              trailing: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Switch(
                    value: _hasBiometricEnabled,
                    onChanged: (_) => _toggleBiometric(),
                    activeColor: Themecolor.purple,
                  ),
              onTap: _isLoading ? null : _toggleBiometric,
            ),
            const Divider(),
          ],
          
          // Logout
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
              size: 28,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Sign out of your account'),
            onTap: _showLogoutConfirmation,
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}