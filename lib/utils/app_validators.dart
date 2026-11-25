import 'package:flutter/services.dart';

class AppValidators {
  // --- Input Formatters ---

  /// Formatter to restrict input to digits only (automatically prevents spaces, letters, and special characters)
  static List<TextInputFormatter> get digitsOnly => [
    FilteringTextInputFormatter.digitsOnly,
  ];

  /// Formatter to deny leading whitespace and consecutive spaces
  static List<TextInputFormatter> get noInitialSpace => [
    MultipleSpaceBlockingFormatter(),
  ];

  /// Formatter to completely deny any whitespace/space character
  static List<TextInputFormatter> get denyAllSpaces => [
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
  ];

  /// Formatter to lowercase email inputs and validate email structures
  static List<TextInputFormatter> get emailFormatters => [
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    EmailInputFormatter(),
  ];

  /// Formatter to restrict input to English letters and spaces (blocking consecutive spaces)
  static List<TextInputFormatter> get alphabetsOnly => [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
    MultipleSpaceBlockingFormatter(),
  ];

  // --- Field Validators ---

  /// Validates that the user is at least 18 years old based on the dob string (DD/MM/YYYY)
  static String? validateDOB(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your date of birth";
    }

    final parts = value.split('/');
    if (parts.length != 3) {
      return "Invalid date format";
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (month == null || day == null || year == null) {
      return "Invalid date format";
    }

    final dob = DateTime(year, month, day);
    final today = DateTime.now();

    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day <= dob.day)) {
      age--;
    }

    if (age < 18) {
      return "You must be at least 18 years old to register";
    }

    return null;
  }

  /// Validates a password field (non-empty, minimum length 6, no spaces)
  static String? validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return "Please enter your password";
    }
    if (password.contains(" ")) {
      return "Password cannot contain spaces";
    }
    if (password.trim().length < 6) {
      return "Password must be at least 6 characters long";
    }
    return null;
  }

  /// Validates a confirm password field (non-empty, matches original password)
  static String? validateConfirmPassword(
    String? confirmPassword,
    String password,
  ) {
    if (confirmPassword == null || confirmPassword.trim().isEmpty) {
      return "Please confirm your password";
    }
    if (confirmPassword != password) {
      return "Passwords do not match";
    }
    return null;
  }

  /// Validates an email field
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return "Please enter your email";
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email.trim())) {
      return "Please enter a valid email address";
    }
    return null;
  }

  /// Validates standard text fields like first/last name
  static String? validateRequiredField(
    String? value, {
    required String fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your $fieldName";
    }
    return null;
  }

  /// Formatter for a clean Full Name (no leading spaces, no consecutive spaces)
  static List<TextInputFormatter> get fullNameFormatters => [
    FullNameFormatter(),
  ];

  /// Validates a clean Full Name (non-empty, no leading/trailing spaces, contains both first and last name)
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your full name";
    }
    if (value.startsWith(' ') || value.endsWith(' ')) {
      return "Name cannot start or end with a space";
    }
    if (value.contains('  ')) {
      return "Multiple consecutive spaces are not allowed";
    }
    return null;
  }

  /// Formatter to restrict to maximum 2 digits only
  static List<TextInputFormatter> get afterServiceResponseFormatters => [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(2),
  ];

  /// Validates after service response (non-empty, valid number)
  static String? validateAfterServiceResponse(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter after service response";
    }
    final intVal = int.tryParse(value);
    if (intVal == null) {
      return "Please enter a valid number";
    }
    return null;
  }

  /// Formatter for experience (decimal value, max 2 digits before dot, max 1 digit after dot)
  static List<TextInputFormatter> get experienceFormatters => [
    ExperienceFormatter(),
  ];
}

class FullNameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. If the text is being deleted (backspace), always allow it
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    final String newText = newValue.text;

    // 2. Prevent leading spaces
    if (newText.startsWith(' ')) {
      return oldValue;
    }

    // 3. Prevent consecutive spaces (multiple spaces)
    if (newText.contains('  ')) {
      return oldValue;
    }

    // 4. Keep only alphabets and spaces (deny digits, special characters, symbols, etc.)
    final RegExp allowedRegex = RegExp(r'^[a-zA-Z\s]*$');
    if (!allowedRegex.hasMatch(newText)) {
      return oldValue;
    }

    return newValue;
  }
}

class ExperienceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    final String newText = newValue.text;
    final RegExp allowedRegex = RegExp(r'^\d{0,2}$');
    if (!allowedRegex.hasMatch(newText)) {
      return oldValue;
    }

    if (newText.isNotEmpty) {
      final intVal = int.tryParse(newText);
      if (intVal == null || intVal > 50) {
        return oldValue;
      }
    }

    return newValue;
  }
}

class EmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.toLowerCase();

    // Deny multiple '@'
    if (RegExp(r'@').allMatches(text).length > 1) {
      return oldValue;
    }

    // Deny consecutive dots '..'
    if (text.contains('..')) {
      return oldValue;
    }

    // Deny dot immediately before or after '@' (e.g. '@.' or '.@')
    if (text.contains('.@') || text.contains('@.')) {
      return oldValue;
    }

    // Split by '@' to check dot counts
    final parts = text.split('@');
    if (parts.isNotEmpty) {
      // Username part: at most 1 dot (e.g. first.last)
      final username = parts[0];
      if (RegExp(r'\.').allMatches(username).length > 1) {
        return oldValue;
      }

      if (parts.length > 1) {
        // Domain part: at most 2 dots (e.g. domain.co.uk)
        final domain = parts[1];
        if (RegExp(r'\.').allMatches(domain).length > 2) {
          return oldValue;
        }
      }
    }

    return newValue.copyWith(text: text, selection: newValue.selection);
  }
}

class MultipleSpaceBlockingFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }
    final String newText = newValue.text;
    if (newText.startsWith(' ')) {
      return oldValue;
    }
    if (newText.contains('  ')) {
      return oldValue;
    }
    return newValue;
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
