import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../core/services/token_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final TokenService _tokenService = TokenService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  UserModel? get currentUser => _currentUser;

  // =========================================================
  // SIGN UP
  // =========================================================

  Future<void> signUp(UserModel user) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.signUp(user);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // -------------------------------------------------------
      // Login and receive JWT
      // -------------------------------------------------------

      final token = await _repository.login(
        email: email,
        password: password,
      );

      // -------------------------------------------------------
      // Remember Me
      // -------------------------------------------------------

      await _tokenService.setToken(
        token,
        rememberMe: rememberMe,
      );

      // -------------------------------------------------------
      // Fetch currently logged-in user
      // -------------------------------------------------------

      _currentUser = await _repository.getCurrentUser(
        token: token,
      );

      // -------------------------------------------------------
      // Login complete
      // -------------------------------------------------------

      _isLoggedIn = true;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // CHANGE PASSWORD
  // =========================================================

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found.");
      }

      await _repository.changePassword(
        token: token,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // FORGOT PASSWORD - CHECK PHONE
  // =========================================================

  Future<Map<String, dynamic>> checkForgotPasswordPhone({
    required String phoneNumber,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      return await _repository.checkForgotPasswordPhone(
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // FORGOT PASSWORD - RESET PASSWORD
  // =========================================================

  Future<void> resetForgotPassword({
    required String phoneNumber,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.resetForgotPassword(
        phoneNumber: phoneNumber,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // PHONE VERIFICATION
  // =========================================================

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================
  // OTP VERIFICATION
  // =========================================================

  Future<void> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // RESTORE SESSION
  // =========================================================

  Future<String?> getStoredToken() async {
    return await _tokenService.getToken();
  }

  Future<void> restoreSession() async {
    final token = await _tokenService.getToken();

    if (token == null || token.isEmpty) {
      return;
    }

    try {
      _currentUser = await _repository.getCurrentUser(
        token: token,
      );

      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      await _tokenService.deleteToken();

      _currentUser = null;
      _isLoggedIn = false;

      rethrow;
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout() async {
    await _tokenService.deleteToken();

    _currentUser = null;
    _isLoggedIn = false;

    notifyListeners();
  }
}