import 'package:flutter/material.dart';

import '../models/group_model.dart';
import '../repositories/group_repository.dart';
import '../core/services/token_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupRepository _repository = GroupRepository();
  final TokenService _tokenService = TokenService();

  bool _isLoading = false;
  List<GroupModel> _groups = [];

  bool get isLoading => _isLoading;
  List<GroupModel> get groups => _groups;

  Future<void> fetchGroups() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      _groups = await _repository.getMyGroups(
        token: token,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGroup({
    required String groupName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      final GroupModel newGroup = await _repository.createGroup(
        token: token,
        groupName: groupName,
      );

      _groups.add(newGroup);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearGroups() {
    _groups.clear();
    notifyListeners();
  }
}