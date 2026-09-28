import '../core/services/group_service.dart';
import '../models/group_model.dart';

class GroupRepository {
  final GroupService _groupService = GroupService();

  Future<List<GroupModel>> getMyGroups({
    required String token,
  }) async {
    final response = await _groupService.getMyGroups(
      token: token,
    );

    final List<dynamic> data = response.data;

    return data
        .map((group) => GroupModel.fromJson(group))
        .toList();
  }

  Future<GroupModel> createGroup({
    required String token,
    required String groupName,
  }) async {
    final response = await _groupService.createGroup(
      token: token,
      groupName: groupName,
    );

    return GroupModel.fromJson(response.data);
  }
}