import 'package:dio/dio.dart';

import '../../models/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:5000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<Response> signUp(UserModel user) async {
    try {
      return await _dio.post(
        '/api/auth/signup',
        data: user.toJson(),
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
}