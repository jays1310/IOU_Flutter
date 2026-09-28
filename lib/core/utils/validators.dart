class Validators {
  Validators._();

  static bool isValidUsername(String username) {
    return username.trim().isNotEmpty;
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    return emailRegex.hasMatch(email.trim());
  }

  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  static bool doPasswordsMatch(
      String password,
      String confirmPassword,
      ) {
    return password == confirmPassword;
  }
}