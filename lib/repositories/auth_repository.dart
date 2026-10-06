import 'package:firebase_auth/firebase_auth.dart';

import '../core/services/auth_service.dart';
import '../core/services/firebase/firebase_auth_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthService _authService = AuthService();
  final FirebaseAuthService _firebaseAuthService =
  FirebaseAuthService();

  // =========================================================
  // SIGN UP
  // =========================================================

  Future<void> signUp(UserModel user) async {
    await _authService.signUp(user);
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _authService.login(
      email: email,
      password: password,
    );

    return response.data['token'];
  }

  // =========================================================
  // GET CURRENT USER
  // =========================================================

  Future<UserModel> getCurrentUser({
    required String token,
  }) async {
    final response = await _authService.getCurrentUser(
      token: token,
    );

    return UserModel.fromJson(
      response.data,
    );
  }

  // =========================================================
  // CHANGE PASSWORD
  // =========================================================

  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    await _authService.changePassword(
      token: token,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  // =========================================================
  // FORGOT PASSWORD - CHECK PHONE
  // =========================================================

  Future<Map<String, dynamic>> checkForgotPasswordPhone({
    required String phoneNumber,
  }) async {
    final response =
    await _authService.checkForgotPasswordPhone(
      phoneNumber: phoneNumber,
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

  // =========================================================
  // FORGOT PASSWORD - RESET PASSWORD
  // =========================================================

  Future<void> resetForgotPassword({
    required String phoneNumber,
    required String newPassword,
  }) async {
    await _authService.resetForgotPassword(
      phoneNumber: phoneNumber,
      newPassword: newPassword,
    );
  }

  // =========================================================
  // FIREBASE PHONE VERIFICATION
  // =========================================================

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout
    codeAutoRetrievalTimeout,
  }) async {
    await _firebaseAuthService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // =========================================================
  // FIREBASE OTP
  // =========================================================

  Future<void> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    await _firebaseAuthService.verifyOtp(
      verificationId: verificationId,
      otp: otp,
    );
  }
}