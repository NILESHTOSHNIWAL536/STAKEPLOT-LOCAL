class InputValidator {
  /// Generic empty check
  static String? _required(String? value, {String fieldName = "Field"}) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  /// Username: letters, numbers, underscore, 3–20 chars
  static String? username(String? value) {
    final requiredCheck = _required(value, fieldName: "Username");
    if (requiredCheck != null) return requiredCheck;

    if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(value!)) {
      return "Username must be 3–20 chars, only letters, numbers, and _ allowed";
    }
    return null;
  }

  /// Email format
  static String? email(String? value) {
    final requiredCheck = _required(value, fieldName: "Email");
    if (requiredCheck != null) return requiredCheck;

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
      return "Enter a valid email address";
    }
    return null;
  }

  /// Password: min 8 chars, must contain letters & numbers
  static String? password(String? value) {
    final requiredCheck = _required(value, fieldName: "Password");
    if (requiredCheck != null) return requiredCheck;

    if (value!.length < 8) {
      return "Password must be at least 8 characters";
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return "Password must contain letters & numbers";
    }
    return null;
  }

  /// Phone: only digits, 10–15 chars
  static String? phone(String? value) {
    final requiredCheck = _required(value, fieldName: "Phone number");
    if (requiredCheck != null) return requiredCheck;

    if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value!)) {
      return "Phone number must be 10–15 digits";
    }
    return null;
  }

  /// Comment / free text: allow basic text, max 500 chars
  static String? comment(String? value) {
    final requiredCheck = _required(value, fieldName: "Comment");
    if (requiredCheck != null) return requiredCheck;

    if (value!.length > 500) {
      return "Comment must not exceed 500 characters";
    }
    return null;
  }

  /// Generic min-max length validator
  static String? length(String? value,
      {int min = 0, int max = 255, String fieldName = "Field"}) {
    final requiredCheck = _required(value, fieldName: fieldName);
    if (requiredCheck != null) return requiredCheck;

    if (value!.length < min) return "$fieldName must be at least $min characters";
    if (value.length > max) return "$fieldName must not exceed $max characters";
    return null;
  }

  /// Custom regex validator
  static String? matchPattern(String? value, RegExp pattern,
      {String fieldName = "Field", String? errorMessage}) {
    final requiredCheck = _required(value, fieldName: fieldName);
    if (requiredCheck != null) return requiredCheck;

    if (!pattern.hasMatch(value!)) {
      return errorMessage ?? "$fieldName format is invalid";
    }
    return null;
  }
}
