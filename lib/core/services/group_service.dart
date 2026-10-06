import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class GroupService {
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

  // ================================================================
  // GET MY GROUPS
  // ================================================================

  Future<Response> getMyGroups({
    required String token,
  }) async {
    return await _dio.get(
      '/api/groups/my-groups',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  // ================================================================
  // CREATE GROUP
  // ================================================================

  Future<Response> createGroup({
    required String token,
    required String groupName,
    required List<String> memberPhoneNumbers,
  }) async {
    return await _dio.post(
      '/api/groups/create',
      data: {
        'group_name': groupName,
        'member_phone_numbers': memberPhoneNumbers,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  // ================================================================
  // ADD MEMBERS TO EXISTING GROUP
  // ================================================================

  Future<Response> addMembers({
    required String token,
    required String groupId,
    required List<String> memberPhoneNumbers,
  }) async {
    return await _dio.post(
      '/api/groups/$groupId/add-members',
      data: {
        'member_phone_numbers': memberPhoneNumbers,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  // ================================================================
  // JOIN GROUP USING INVITE CODE
  // ================================================================

  Future<Response> joinGroup({
    required String token,
    required String inviteCode,
  }) async {
    return await _dio.post(
      '/api/groups/join',
      data: {
        'invite_code': inviteCode,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  // ================================================================
  // LEAVE GROUP
  // ================================================================

  Future<Response> leaveGroup({
    required String token,
    required String groupId,
  }) async {
    return await _dio.post(
      '/api/groups/$groupId/leave',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}
