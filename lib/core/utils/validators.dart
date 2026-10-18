class Validators {
  static String? requiredField(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? numericField(String? value, [String fieldName = 'Amount']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final numVal = double.tryParse(value);
    if (numVal == null) {
      return 'Please enter a valid number';
    }
    if (numVal < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  static String? phoneField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.trim().length < 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }
}
