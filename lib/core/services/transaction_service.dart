import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class TransactionService {
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
  // GROUP TRANSACTIONS
  // =========================================================

  Future<Response> createExpense({
    required String token,
    required String groupId,
    required String description,
    required double amount,
    required String paidBy,
    required String splitType,
    required List<Map<String, dynamic>> splitDetails,
  }) async {
    return await _dio.post(
      '/api/transactions/expense',
      data: {
        'group_id': groupId,
        'description': description,
        'amount': amount,
        'paid_by': paidBy,
        'split_type': splitType,
        'split_details': splitDetails,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> createSettlement({
    required String token,
    required String groupId,
    required String receiverId,
    required double amount,
  }) async {
    return await _dio.post(
      '/api/transactions/settlement',
      data: {
        'group_id': groupId,
        'receiver_id': receiverId,
        'amount': amount,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> getGroupTransactions({
    required String token,
    required String groupId,
  }) async {
    return await _dio.get(
      '/api/transactions/group/$groupId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> getGroupBalanceSummary({
    required String token,
    required String groupId,
  }) async {
    return await _dio.get(
      '/api/transactions/group/$groupId/balance',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  // =========================================================
  // INDIVIDUAL TRANSACTIONS
  // =========================================================

  Future<Response> createIndividualExpense({
    required String token,
    required String individualUserId,
    required String description,
    required double amount,
    required String paidBy,
    required String splitType,
    required List<Map<String, dynamic>> splitDetails,
  }) async {
    return await _dio.post(
      '/api/transactions/individual/expense',
      data: {
        'individual_user_id': individualUserId,
        'description': description,
        'amount': amount,
        'paid_by': paidBy,
        'split_type': splitType,
        'split_details': splitDetails,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> getIndividualTransactions({
    required String token,
    required String otherUserId,
  }) async {
    return await _dio.get(
      '/api/transactions/individual/$otherUserId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> getIndividualBalance({
    required String token,
    required String otherUserId,
  }) async {
    return await _dio.get(
      '/api/transactions/individual/$otherUserId/balance',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> getIndividualRelationships({
    required String token,
  }) async {
    return await _dio.get(
      '/api/transactions/individual',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> createIndividualSettlement({
    required String token,
    required String individualUserId,
    required double amount,
  }) async {
    return await _dio.post(
      '/api/transactions/individual/settlement',
      data: {
        'individual_user_id': individualUserId,
        'amount': amount,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}