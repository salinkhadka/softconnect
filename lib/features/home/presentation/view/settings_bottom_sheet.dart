// settings_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/theme/theme_provider.dart';
import 'package:softconnect/features/home/presentation/view_model/homepage_viewmodel.dart';

class SettingsBottomSheet extends StatefulWidget {
  final LocalAuthentication localAuth;
  final HomeViewModel homeViewModel;
  final ThemeProvider themeProvider;

  const SettingsBottomSheet({
    super.key,
    required this.localAuth,
    required this.homeViewModel,
    required this.themeProvider,
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
    } catch (_) {
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

    setState(() => _isLoading = true);

    try {
      if (_hasBiometricEnabled) {
        _showDisableBiometricDialog();
      } else {
        await _enableBiometric();
      }
    } catch (_) {
      if (mounted) _showSnackBar('Failed to toggle biometric setting', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _enableBiometric() async {
    final bool isAuthenticated = await widget.localAuth.authenticate(
      localizedReason: 'Please authenticate to enable biometric login',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    if (!isAuthenticated) {
      if (mounted) _showSnackBar('Authentication failed', isError: true);
      return;
    }

    await _showCredentialsDialog();
  }

  Future<void> _showCredentialsDialog() async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          title: Text('Enable Biometric Login',
              style: Theme.of(context).dialogTheme.titleTextStyle),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Please enter your login credentials:',
                    style: Theme.of(context).dialogTheme.contentTextStyle),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter password' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.of(context).pop(true);
              },
              child: const Text('Save & Enable'),
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
    }
  }

  Future<void> _saveCredentialsAndEnable(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stored_username', email);
    await prefs.setString('stored_password', password);
    await prefs.setBool('biometric_enabled', true);

    if (mounted) {
      setState(() {
        _hasBiometricEnabled = true;
        _isLoading = false;
      });
      _showSnackBar('Biometric login enabled!');
    }
  }

  void _showDisableBiometricDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Text('Disable Biometric Login',
            style: Theme.of(context).dialogTheme.titleTextStyle),
        content: Text(
          'Are you sure you want to disable biometric login?',
          style: Theme.of(context).dialogTheme.contentTextStyle,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Disable', style: TextStyle(color: Colors.red[600])),
          ),
        ],
      ),
    );

    if (result == true) await _disableBiometric();
  }

  Future<void> _disableBiometric() async {
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
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Text('Logout', style: Theme.of(context).dialogTheme.titleTextStyle),
        content: Text('Are you sure you want to logout?',
            style: Theme.of(context).dialogTheme.contentTextStyle),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              widget.homeViewModel.logout(context);
            },
            child: Text('Logout', style: TextStyle(color: Colors.red[600])),
          ),
        ],
      ),
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
    final isDarkMode = widget.themeProvider.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).primaryColor),
            title: Text('Dark Mode',
                style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color)),
            subtitle: Text(
              isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (_) => widget.themeProvider.toggleTheme(),
              activeColor: Theme.of(context).primaryColor,
            ),
            onTap: () => widget.themeProvider.toggleTheme(),
          ),
          const Divider(),
          if (_isBiometricAvailable) ...[
            ListTile(
              leading: Icon(Icons.fingerprint, color: Theme.of(context).primaryColor),
              title: Text('Biometric Login',
                  style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color)),
              subtitle: Text(
                _hasBiometricEnabled ? 'Enabled - Use fingerprint to login' : 'Disabled - Tap to enable biometric login',
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
              ),
              trailing: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Switch(
                      value: _hasBiometricEnabled,
                      onChanged: (_) => _toggleBiometric(),
                      activeColor: Theme.of(context).primaryColor,
                    ),
              onTap: _isLoading ? null : _toggleBiometric,
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            subtitle: Text('Sign out of your account',
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
            onTap: _showLogoutConfirmation,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
