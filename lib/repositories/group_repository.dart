import '../core/services/group_service.dart';
import '../models/group_model.dart';

class GroupRepository {
  final GroupService _groupService = GroupService();

  // ================================================================
  // GET MY GROUPS
  // ================================================================

  Future<List<GroupModel>> getMyGroups({
    required String token,
  }) async {
    final response = await _groupService.getMyGroups(
      token: token,
    );

    return (response.data as List)
        .map(
          (group) => GroupModel.fromJson(group),
    )
        .toList();
  }

  // ================================================================
  // CREATE GROUP
  // ================================================================

  Future<GroupModel> createGroup({
    required String token,
    required String groupName,
    required List<String> memberPhoneNumbers,
  }) async {
    final response = await _groupService.createGroup(
      token: token,
      groupName: groupName,
      memberPhoneNumbers: memberPhoneNumbers,
    );

    return GroupModel.fromJson(response.data);
  }

  // ================================================================
  // ADD MEMBERS TO EXISTING GROUP
  // ================================================================

  Future<GroupModel> addMembers({
    required String token,
    required String groupId,
    required List<String> memberPhoneNumbers,
  }) async {
    final response = await _groupService.addMembers(
      token: token,
      groupId: groupId,
      memberPhoneNumbers: memberPhoneNumbers,
    );

    return GroupModel.fromJson(response.data);
  }

  // ================================================================
  // JOIN GROUP USING INVITE CODE
  // ================================================================

  Future<GroupModel> joinGroup({
    required String token,
    required String inviteCode,
  }) async {
    final response = await _groupService.joinGroup(
      token: token,
      inviteCode: inviteCode,
    );

    return GroupModel.fromJson(response.data);
  }

  // ================================================================
  // LEAVE GROUP
  // ================================================================

  Future<void> leaveGroup({
    required String token,
    required String groupId,
  }) async {
    await _groupService.leaveGroup(
      token: token,
      groupId: groupId,
    );
  }
}