// lib/features/auth/presentation/widget/google_signin_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_event.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkMode 
              ? Colors.grey.shade600 
              : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isDarkMode 
            ? Theme.of(context).cardColor 
            : Colors.white,
        boxShadow: isDarkMode 
            ? null 
            : [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          splashColor: isDarkMode 
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          highlightColor: isDarkMode 
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.05),
          onTap: () {
            context.read<LoginViewModel>().add(
              GoogleLoginEvent(context: context),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://developers.google.com/identity/images/g-logo.png',
                height: 24,
                width: 24,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.login,
                    size: 24,
                    color: isDarkMode 
                        ? Colors.grey.shade400 
                        : Colors.grey.shade600,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDarkMode 
                          ? Colors.grey.shade300 
                          : Colors.grey.shade400,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode 
                      ? Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}