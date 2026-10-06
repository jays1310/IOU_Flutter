import '../core/services/transaction_service.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final TransactionService _transactionService = TransactionService();

  // =========================================================
  // GROUP TRANSACTIONS
  // =========================================================

  Future<Map<String, dynamic>> createExpense({
    required String token,
    required String groupId,
    required String description,
    required double amount,
    required String paidBy,
    required String splitType,
    required List<Map<String, dynamic>> splitDetails,
  }) async {
    final response = await _transactionService.createExpense(
      token: token,
      groupId: groupId,
      description: description,
      amount: amount,
      paidBy: paidBy,
      splitType: splitType,
      splitDetails: splitDetails,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> createSettlement({
    required String token,
    required String groupId,
    required String receiverId,
    required double amount,
  }) async {
    final response = await _transactionService.createSettlement(
      token: token,
      groupId: groupId,
      receiverId: receiverId,
      amount: amount,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<List<TransactionModel>> getGroupTransactions({
    required String token,
    required String groupId,
  }) async {
    final response = await _transactionService.getGroupTransactions(
      token: token,
      groupId: groupId,
    );

    return (response.data as List)
        .map(
          (transaction) => TransactionModel.fromJson(
        Map<String, dynamic>.from(transaction),
      ),
    )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getGroupBalanceSummary({
    required String token,
    required String groupId,
  }) async {
    final response =
    await _transactionService.getGroupBalanceSummary(
      token: token,
      groupId: groupId,
    );

    return (response.data as List)
        .map(
          (balance) => Map<String, dynamic>.from(balance),
    )
        .toList();
  }

  // =========================================================
  // INDIVIDUAL TRANSACTIONS
  // =========================================================

  Future<Map<String, dynamic>> createIndividualExpense({
    required String token,
    required String individualUserId,
    required String description,
    required double amount,
    required String paidBy,
    required String splitType,
    required List<Map<String, dynamic>> splitDetails,
  }) async {
    final response =
    await _transactionService.createIndividualExpense(
      token: token,
      individualUserId: individualUserId,
      description: description,
      amount: amount,
      paidBy: paidBy,
      splitType: splitType,
      splitDetails: splitDetails,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<List<TransactionModel>> getIndividualTransactions({
    required String token,
    required String otherUserId,
  }) async {
    final response =
    await _transactionService.getIndividualTransactions(
      token: token,
      otherUserId: otherUserId,
    );

    return (response.data as List)
        .map(
          (transaction) => TransactionModel.fromJson(
        Map<String, dynamic>.from(transaction),
      ),
    )
        .toList();
  }

  Future<Map<String, dynamic>> getIndividualBalance({
    required String token,
    required String otherUserId,
  }) async {
    final response =
    await _transactionService.getIndividualBalance(
      token: token,
      otherUserId: otherUserId,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getIndividualRelationships({
    required String token,
  }) async {
    final response = await _transactionService.getIndividualRelationships(
      token: token,
    );

    final data = response.data as List;

    return data
        .map(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  Future<Map<String, dynamic>> createIndividualSettlement({
    required String token,
    required String individualUserId,
    required double amount,
  }) async {
    final response = await _transactionService.createIndividualSettlement(
      token: token,
      individualUserId: individualUserId,
      amount: amount,
    );

    return Map<String, dynamic>.from(response.data);
  }
}