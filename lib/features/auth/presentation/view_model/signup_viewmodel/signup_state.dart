// signup_state.dart
class SignupState {
  final bool isLoading;
  final bool isSuccess;
  final String? message;
  final String? profilePhotoPath;
  final bool agreedToTerms;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? selectedProgram;

  const SignupState({
    required this.isLoading,
    required this.isSuccess,
    this.message,
    this.profilePhotoPath,
    required this.agreedToTerms,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    this.selectedProgram,
  });

  factory SignupState.initial() {
    return const SignupState(
      isLoading: false,
      isSuccess: false,
      message: null,
      profilePhotoPath: null,
      agreedToTerms: false,
      obscurePassword: true,
      obscureConfirmPassword: true,
      selectedProgram: null,
    );
  }

  SignupState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? message,
    String? profilePhotoPath,
    bool? agreedToTerms,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    String? selectedProgram,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      message: message,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      selectedProgram: selectedProgram ?? this.selectedProgram,
    );
  }
}