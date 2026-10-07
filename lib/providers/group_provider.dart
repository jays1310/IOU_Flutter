import 'package:dio/dio.dart';
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

  // ================================================================
  // FETCH GROUPS
  // ================================================================

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

  // ================================================================
  // CREATE GROUP
  // ================================================================

  Future<GroupModel> createGroup({
    required String groupName,
    required List<String> memberPhoneNumbers,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      final GroupModel newGroup =
      await _repository.createGroup(
        token: token,
        groupName: groupName,
        memberPhoneNumbers: memberPhoneNumbers,
      );

      _groups.add(newGroup);

      return newGroup;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================================================
  // ADD MEMBERS TO EXISTING GROUP
  // ================================================================

  Future<GroupModel> addMembers({
    required String groupId,
    required List<String> memberPhoneNumbers,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      final GroupModel updatedGroup =
      await _repository.addMembers(
        token: token,
        groupId: groupId,
        memberPhoneNumbers: memberPhoneNumbers,
      );

      // ------------------------------------------------------------
      // Update the corresponding group in the provider
      // ------------------------------------------------------------

      final index = _groups.indexWhere(
            (group) => group.id == updatedGroup.id,
      );

      if (index != -1) {
        _groups[index] = updatedGroup;
      }

      return updatedGroup;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================================================
  // JOIN GROUP USING INVITE CODE
  // ================================================================

  Future<GroupModel> joinGroup({
    required String inviteCode,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      final GroupModel joinedGroup =
      await _repository.joinGroup(
        token: token,
        inviteCode: inviteCode,
      );

      // ------------------------------------------------------------
      // Add the joined group to the provider if it is not already
      // present.
      // ------------------------------------------------------------

      final index = _groups.indexWhere(
            (group) => group.id == joinedGroup.id,
      );

      if (index == -1) {
        _groups.add(joinedGroup);
      } else {
        _groups[index] = joinedGroup;
      }

      return joinedGroup;
    } on DioException catch (e) {
      // ------------------------------------------------------------
      // Extract the actual error message returned by Flask
      // ------------------------------------------------------------

      final responseData = e.response?.data;

      if (responseData is Map<String, dynamic>) {
        final errorMessage = responseData['error'];

        if (errorMessage is String &&
            errorMessage.isNotEmpty) {
          throw Exception(errorMessage);
        }
      }

      throw Exception(
        'Unable to join the group. Please try again.',
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================================================
  // LEAVE GROUP
  // ================================================================

  Future<void> leaveGroup({
    required String groupId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _tokenService.getToken();

      if (token == null) {
        throw Exception('User is not logged in.');
      }

      await _repository.leaveGroup(
        token: token,
        groupId: groupId,
      );

      // ------------------------------------------------------------
      // Remove the group from the local provider
      // ------------------------------------------------------------

      _groups.removeWhere(
            (group) => group.id == groupId,
      );
    } on DioException catch (e) {
      // ------------------------------------------------------------
      // Extract the actual error message returned by Flask
      // ------------------------------------------------------------

      final responseData = e.response?.data;

      if (responseData is Map<String, dynamic>) {
        final errorMessage = responseData['error'];

        if (errorMessage is String &&
            errorMessage.isNotEmpty) {
          throw Exception(errorMessage);
        }
      }

      throw Exception(
        'Unable to leave the group. Please try again.',
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================================================
  // CLEAR GROUPS
  // ================================================================

  void clearGroups() {
    _groups.clear();
    notifyListeners();
  }
}