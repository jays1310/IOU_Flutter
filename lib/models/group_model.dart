class GroupMemberModel {
  final String id;
  final String username;
  final String phoneNumber;

  const GroupMemberModel({
    required this.id,
    required this.username,
    required this.phoneNumber,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phoneNumber': phoneNumber,
    };
  }
}

class GroupModel {
  final String id;
  final String groupName;
  final String createdBy;
  final List<String> members;
  final List<GroupMemberModel> memberDetails;
  final String inviteCode;
  final DateTime createdAt;

  // Latest expense/settlement activity in this group.
  final DateTime? lastActivity;

  // Current user's outstanding balances.
  //
  // iOwe   = amount the current user owes to other members.
  // owesMe = amount other members owe to the current user.
  final double iOwe;
  final double owesMe;

  const GroupModel({
    required this.id,
    required this.groupName,
    required this.createdBy,
    required this.members,
    required this.memberDetails,
    required this.inviteCode,
    required this.createdAt,
    required this.lastActivity,
    required this.iOwe,
    required this.owesMe,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['_id'] ?? json['id'] ?? '',
      groupName: json['group_name'] ?? '',
      createdBy: json['created_by'] ?? '',
      members: List<String>.from(json['members'] ?? []),
      memberDetails: (json['member_details'] as List? ?? [])
          .map(
            (member) => GroupMemberModel.fromJson(
              Map<String, dynamic>.from(member),
            ),
          )
          .toList(),
      inviteCode: json['invite_code'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      lastActivity: json['last_activity'] != null
          ? DateTime.parse(json['last_activity'])
          : null,
      iOwe: (json['i_owe'] as num?)?.toDouble() ?? 0.0,
      owesMe: (json['owes_me'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'group_name': groupName,
      'created_by': createdBy,
      'members': members,
      'member_details': memberDetails
          .map((member) => member.toJson())
          .toList(),
      'invite_code': inviteCode,
      'created_at': createdAt.toIso8601String(),
      'last_activity': lastActivity?.toIso8601String(),
      'i_owe': iOwe,
      'owes_me': owesMe,
    };
  }

  GroupModel copyWith({
    String? id,
    String? groupName,
    String? createdBy,
    List<String>? members,
    List<GroupMemberModel>? memberDetails,
    String? inviteCode,
    DateTime? createdAt,
    DateTime? lastActivity,
    double? iOwe,
    double? owesMe,
  }) {
    return GroupModel(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      memberDetails: memberDetails ?? this.memberDetails,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      iOwe: iOwe ?? this.iOwe,
      owesMe: owesMe ?? this.owesMe,
    );
  }
}
