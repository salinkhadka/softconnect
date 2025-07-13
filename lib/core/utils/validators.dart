// lib/core/utils/validators.dart

bool isValidStudentId(String id) {
  final number = int.tryParse(id);
  return number != null && id.length == 6;
}

bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  return emailRegex.hasMatch(email);
}

bool isValidPassword(String password) {
  return password.length >= 6;
}

bool doPasswordsMatch(String pass1, String pass2) {
  return pass1 == pass2;
}
