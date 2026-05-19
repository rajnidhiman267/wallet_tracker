class AppValidator {
  // ============================================================
  // 🔹 REGEX PATTERNS
  // ============================================================

  final String _emailRegex =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  final String _passwordRegex =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';

  // ============================================================
  // 🔹 VALIDATION METHODS
  // ============================================================

  String? email(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required.";
    }
    if (!isValidEmail(value)) {
      return "Enter a valid email.";
    }
    return null;
  }

  String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required.";
    }
    if (!isValidPassword(value) || value.length < 6) {
      return "Password must be at least 6 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character.";
    }
    return null;
  }

  String? confirmPassword({
    required String? value,
    required String? originalPassword,
  }) {
    if (value == null || value.isEmpty) {
      return "Password is required.";
    }
    if (originalPassword == null || originalPassword.isEmpty) {
      return "Password is required.";
    }
    if (value != originalPassword) {
      return "Passwords do not match.";
    }
    return null;
  }

  // Fixed: Proper fieldName handling
  String? requiredField(String? value, {String fieldName = ""}) {
    if (value == null || value.isEmpty) {
      if (fieldName.isNotEmpty) {
        return "Please enter $fieldName.";
      }
      return "Field is required.";
    }
    return null;
  }

  // ============================================================
  // 🔹 REGEX HELPERS
  // ============================================================

  bool isValidEmail(String value) {
    return RegExp(_emailRegex).hasMatch(value.trim());
  }

  bool isValidPassword(String value) {
    return RegExp(_passwordRegex).hasMatch(value.trim());
  }
}
