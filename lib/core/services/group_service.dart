import 'package:dio/dio.dart';

class GroupService {
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

  Future<Response> createGroup({
    required String token,
    required String groupName,
  }) async {
    return await _dio.post(
      '/api/groups/create',
      data: {
        'group_name': groupName,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}