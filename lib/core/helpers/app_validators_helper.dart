import 'package:insurflow/core/helpers/app_regex.dart';

class AppValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    if (!AppRegex.isEmailValid(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or phone is required';
    }

    final input = value.trim();
    if (input.contains('@')) {
      if (!AppRegex.isEmailValid(input)) {
        return 'Please enter a valid email address';
      }
      return null;
    }

    final digits = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(digits)) {
      return 'Please enter a valid email or phone';
    }
    return null;
  }

  static String? requiredTrimmed(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? validateLoginPassword(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return message ?? 'Password is required';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!AppRegex.isPasswordValid(value)) {
      return 'Must be at least 8 characters with one number and one special character';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }


  static String? validateAgeConfirmation(bool? value) {
    if (value != true) {
      return 'You must be at least 18 years old to proceed';
    }
    return null;
  }
}