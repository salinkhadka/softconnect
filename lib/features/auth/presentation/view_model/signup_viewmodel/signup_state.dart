import 'package:equatable/equatable.dart';

class SignupState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? profilePhotoPath;
  final bool agreedToTerms;

  const SignupState({
    required this.isLoading,
    required this.isSuccess,
    this.profilePhotoPath,
    required this.agreedToTerms,
  });

  factory SignupState.initial() => const SignupState(
        isLoading: false,
        isSuccess: false,
        profilePhotoPath: null,
        agreedToTerms: false,
      );

  SignupState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? profilePhotoPath,
    bool? agreedToTerms,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, profilePhotoPath, agreedToTerms];
}
