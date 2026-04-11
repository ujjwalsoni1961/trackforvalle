class Validator {
  static bool validateEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  static bool validatePhone(String phone) =>
      RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone);

  static bool validateName(String name) =>
      RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
}
