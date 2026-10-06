class TransactionParticipant {
  final String userId;
  final double share;

  const TransactionParticipant({
    required this.userId,
    required this.share,
  });

  factory TransactionParticipant.fromJson(
      Map<String, dynamic> json,
      ) {
    return TransactionParticipant(
      userId: json['user_id'] ?? '',
      share: (json['share'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'share': share,
    };
  }
}

class TransactionSplitDetail {
  final String userId;
  final double value;

  const TransactionSplitDetail({
    required this.userId,
    required this.value,
  });

  factory TransactionSplitDetail.fromJson(
      Map<String, dynamic> json,
      ) {
    return TransactionSplitDetail(
      userId: json['user_id'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'value': value,
    };
  }
}

class TransactionModel {
  final String id;
  final String? groupId;
  final String? individualUserId;
  final String transactionType;
  final String description;
  final double amount;
  final String createdBy;
  final String? paidBy;
  final List<TransactionParticipant> participants;
  final String splitType;
  final List<TransactionSplitDetail> splitDetails;
  final String? payer;
  final String? receiver;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.groupId,
    required this.individualUserId,
    required this.transactionType,
    required this.description,
    required this.amount,
    required this.createdBy,
    required this.paidBy,
    required this.participants,
    required this.splitType,
    required this.splitDetails,
    required this.payer,
    required this.receiver,
    required this.createdAt,
  });

  // ---------------------------------------------------------------
  // Parse backend UTC timestamp and convert it to device local time.
  //
  // Backend currently sends UTC timestamps without a timezone suffix,
  // for example:
  //
  // 2026-10-01T18:43:00.123456
  //
  // The backend value is UTC, so we explicitly append "Z" before
  // converting it to the device's local timezone.
  // ---------------------------------------------------------------

  static DateTime _parseCreatedAt(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    final raw = value.toString();

    final parsed = DateTime.parse(raw);

    // If the backend already sends a timezone-aware timestamp,
    // simply convert it to local time.
    if (parsed.isUtc) {
      return parsed.toLocal();
    }

    // Current backend sends UTC without a timezone suffix.
    // Explicitly treat that value as UTC before converting to local.
    return DateTime.parse('${raw}Z').toLocal();
  }

  factory TransactionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return TransactionModel(
      id: json['id'] ?? '',
      groupId: json['group_id'],
      individualUserId: json['individual_user_id'],
      transactionType:
      json['transaction_type'] ?? '',
      description:
      json['description'] ?? '',
      amount:
      (json['amount'] as num?)?.toDouble() ?? 0.0,
      createdBy:
      json['created_by'] ?? '',
      paidBy:
      json['paid_by'],

      participants:
      (json['participants'] as List? ?? [])
          .map(
            (participant) =>
            TransactionParticipant.fromJson(
              Map<String, dynamic>.from(
                participant,
              ),
            ),
      )
          .toList(),

      splitType:
      json['split_type'] ?? 'equal',

      splitDetails:
      (json['split_details'] as List? ?? [])
          .map(
            (detail) =>
            TransactionSplitDetail.fromJson(
              Map<String, dynamic>.from(
                detail,
              ),
            ),
      )
          .toList(),

      payer:
      json['payer'],

      receiver:
      json['receiver'],

      createdAt:
      _parseCreatedAt(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,

      if (groupId != null)
        'group_id': groupId,

      if (individualUserId != null)
        'individual_user_id':
        individualUserId,

      'transaction_type':
      transactionType,

      'description':
      description,

      'amount':
      amount,

      'created_by':
      createdBy,

      'paid_by':
      paidBy,

      'participants':
      participants
          .map(
            (participant) =>
            participant.toJson(),
      )
          .toList(),

      'split_type':
      splitType,

      'split_details':
      splitDetails
          .map(
            (detail) =>
            detail.toJson(),
      )
          .toList(),

      'payer':
      payer,

      'receiver':
      receiver,

      'created_at':
      createdAt.toIso8601String(),
    };
  }
}