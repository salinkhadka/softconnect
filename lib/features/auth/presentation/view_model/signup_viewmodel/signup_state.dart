import 'package:equatable/equatable.dart';

class SignupState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? profilePhotoPath;
  final bool agreedToTerms;
  final String? message;  // add message here

  const SignupState({
    required this.isLoading,
    required this.isSuccess,
    this.profilePhotoPath,
    required this.agreedToTerms,
    this.message,
  });

  factory SignupState.initial() => const SignupState(
        isLoading: false,
        isSuccess: false,
        profilePhotoPath: null,
        agreedToTerms: false,
        message: null,   // default null
      );

  SignupState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? profilePhotoPath,
    bool? agreedToTerms,
    String? message,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, profilePhotoPath, agreedToTerms, message];
}
