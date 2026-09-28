class GroupModel {
  final String id;
  final String groupName;
  final String createdBy;
  final List<String> members;
  final String inviteCode;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.groupName,
    required this.createdBy,
    required this.members,
    required this.inviteCode,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] ?? '',
      groupName: json['group_name'] ?? '',
      createdBy: json['created_by'] ?? '',
      members: List<String>.from(json['members'] ?? []),
      inviteCode: json['invite_code'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_name': groupName,
      'created_by': createdBy,
      'members': members,
      'invite_code': inviteCode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  GroupModel copyWith({
    String? id,
    String? groupName,
    String? createdBy,
    List<String>? members,
    String? inviteCode,
    DateTime? createdAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}