/// Form validators
class Validators {
  Validators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate name
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validate confirm password
  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value != password) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  /// Validate number input
  static String? positiveNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return 'Please enter a valid positive number';
    }
    return null;
  }
}
