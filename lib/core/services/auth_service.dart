import 'package:dio/dio.dart';

import '../../models/user_model.dart';
import '../../core/constants/api_constants.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // =========================================================
  // SIGN UP
  // =========================================================

  Future<Response> signUp(UserModel user) async {
    try {
      return await _dio.post(
        '/api/auth/register',
        data: user.toJson(),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['error'] ?? 'Signup failed');
      }

      throw Exception('Unable to connect to server.');
    }
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await _dio.post(
      '/api/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  // =========================================================
  // GET CURRENT USER
  // =========================================================

  Future<Response> getCurrentUser({
    required String token,
  }) async {
    return await _dio.get(
      '/api/auth/me',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  // =========================================================
  // CHANGE PASSWORD
  // =========================================================

  Future<Response> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      return await _dio.put(
        '/api/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data['error'] != null) {
        throw Exception(e.response!.data['error']);
      }

      throw Exception("Unable to connect to server.");
    }
  }

  // =========================================================
  // FORGOT PASSWORD - CHECK PHONE
  // =========================================================

  Future<Response> checkForgotPasswordPhone({
    required String phoneNumber,
  }) async {
    try {
      return await _dio.post(
        '/api/auth/forgot-password/check-phone',
        data: {
          'phoneNumber': phoneNumber,
        },
      );
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data['error'] != null) {
        throw Exception(e.response!.data['error']);
      }

      throw Exception("Unable to connect to server.");
    }
  }

  // =========================================================
  // FORGOT PASSWORD - RESET PASSWORD
  // =========================================================

  Future<Response> resetForgotPassword({
    required String phoneNumber,
    required String newPassword,
  }) async {
    try {
      return await _dio.put(
        '/api/auth/forgot-password/reset',
        data: {
          'phoneNumber': phoneNumber,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data['error'] != null) {
        throw Exception(e.response!.data['error']);
      }

      throw Exception("Unable to connect to server.");
    }
  }
}
