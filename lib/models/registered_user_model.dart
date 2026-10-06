class RegisteredUserModel {
  final String id;
  final String username;
  final String phoneNumber;
  final String email;

  const RegisteredUserModel({
    required this.id,
    required this.username,
    required this.phoneNumber,
    required this.email,
  });

  factory RegisteredUserModel.fromJson(Map<String, dynamic> json) {
    return RegisteredUserModel(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}