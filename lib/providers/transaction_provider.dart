import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../core/services/token_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();
  final TokenService _tokenService = TokenService();

  bool _isLoading = false;

  // =========================================================
  // GROUP TRANSACTIONS
  // =========================================================

  List<TransactionModel> _transactions = [];

  List<Map<String, dynamic>> _groupBalances = [];

  // =========================================================
  // INDIVIDUAL TRANSACTIONS
  // =========================================================

  List<TransactionModel> _individualTransactions = [];

  Map<String, dynamic>? _individualBalance;

  List<Map<String, dynamic>> _individualRelationships = [];

  // =========================================================
  // GETTERS
  // =========================================================

  bool get isLoading => _isLoading;

  // Group getters

  List<TransactionModel> get transactions => _transactions;

  List<Map<String, dynamic>> get groupBalances => _groupBalances;

  // Individual getters

  List<TransactionModel> get individualTransactions =>
      _individualTransactions;

  Map<String, dynamic>? get individualBalance =>
      _individualBalance;

  List<Map<String, dynamic>> get individualRelationships =>
      _individualRelationships;

  // =========================================================
  // GROUP TRANSACTIONS
  // =========================================================

  Future<Map<String, dynamic>> createExpense({
    required String groupId,
    required String description,
    required double amount,
    required String paidBy,
    required String splitType,
    required List<Map<String, dynamic>> splitDetails,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      return await _repository.createExpense(
        token: token,
        groupId: groupId,
        description: description,
        amount: amount,
        paidBy: paidBy,
        splitType: splitType,
        splitDetails: splitDetails,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createSettlement({
    required String groupId,
    required String receiverId,
    required double amount,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      return await _repository.createSettlement(
        token: token,
        groupId: groupId,
        receiverId: receiverId,
        amount: amount,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getGroupTransactions({
    required String groupId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      _transactions = await _repository.getGroupTransactions(
        token: token,
        groupId: groupId,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getGroupBalanceSummary({
    required String groupId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      final balances = await _repository.getGroupBalanceSummary(
        token: token,
        groupId: groupId,
      );

      _groupBalances = balances;

      return balances;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearGroupBalances() {
    _groupBalances = [];
    notifyListeners();
  }

  // =========================================================
  // INDIVIDUAL TRANSACTIONS
  // =========================================================

  Future<Map<String, dynamic>> createIndividualExpense({
    required String individualUserId,
    required String description,
    required double amount,
    required String paidBy,
    required String splitType,
    required List<Map<String, dynamic>> splitDetails,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      return await _repository.createIndividualExpense(
        token: token,
        individualUserId: individualUserId,
        description: description,
        amount: amount,
        paidBy: paidBy,
        splitType: splitType,
        splitDetails: splitDetails,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getIndividualTransactions({
    required String otherUserId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      _individualTransactions =
      await _repository.getIndividualTransactions(
        token: token,
        otherUserId: otherUserId,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getIndividualBalance({
    required String otherUserId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      final balance = await _repository.getIndividualBalance(
        token: token,
        otherUserId: otherUserId,
      );

      _individualBalance = balance;

      return balance;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // INDIVIDUAL RELATIONSHIPS
  // =========================================================

  Future<void> getIndividualRelationships() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      _individualRelationships =
      await _repository.getIndividualRelationships(
        token: token,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // INDIVIDUAL SETTLEMENT
  // =========================================================

  Future<Map<String, dynamic>> createIndividualSettlement({
    required String individualUserId,
    required double amount,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      return await _repository.createIndividualSettlement(
        token: token,
        individualUserId: individualUserId,
        amount: amount,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // CLEAR INDIVIDUAL DATA
  // =========================================================

  void clearIndividualTransactions() {
    _individualTransactions = [];
    notifyListeners();
  }

  void clearIndividualBalance() {
    _individualBalance = null;
    notifyListeners();
  }

  void clearIndividualRelationships() {
    _individualRelationships = [];
    notifyListeners();
  }
}