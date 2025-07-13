import 'package:flutter_test/flutter_test.dart';
import 'package:softconnect/core/utils/validators.dart';

void main() {
  group('Validators tests', () {
    test('isValidStudentId returns true for valid 6-digit number', () {
      expect(isValidStudentId('123456'), true);
    });

    test('isValidStudentId returns false for non-numeric string', () {
      expect(isValidStudentId('abc123'), false);
    });

    test('isValidStudentId returns false for number with less than 6 digits', () {
      expect(isValidStudentId('12345'), false);
    });

    test('isValidEmail returns true for valid email', () {
      expect(isValidEmail('test@example.com'), true);
    });

    test('isValidEmail returns false for invalid email', () {
      expect(isValidEmail('testexample.com'), false);
    });

    test('isValidPassword returns true for password length >= 6', () {
      expect(isValidPassword('abcdef'), true);
    });

    test('isValidPassword returns false for password length < 6', () {
      expect(isValidPassword('abc'), false);
    });

    test('doPasswordsMatch returns true when passwords are same', () {
      expect(doPasswordsMatch('password123', 'password123'), true);
    });

    test('doPasswordsMatch returns false when passwords are different', () {
      expect(doPasswordsMatch('password123', 'pass123'), false);
    });
  });
}
