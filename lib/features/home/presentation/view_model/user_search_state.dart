import 'package:equatable/equatable.dart';

class UserSearchState extends Equatable {
  final bool isLoading;
  final List<UserSearchResult> results;
  final String? error;

  const UserSearchState({
    this.isLoading = false,
    this.results = const [],
    this.error,
  });

  UserSearchState copyWith({
    bool? isLoading,
    List<UserSearchResult>? results,
    String? error,
  }) {
    return UserSearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, results, error];
}

// Define a simple model for search results
class UserSearchResult extends Equatable {
  final String? id;
  final String username;
  final String? email;
  final String? profilePhoto;

  const UserSearchResult({
     this.id,
    required this.username,
    this.email,
    this.profilePhoto,
  });

  @override
  List<Object?> get props => [id, username, email, profilePhoto];

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      profilePhoto: json['profilePhoto'],
    );
  }
}
