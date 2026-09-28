class UserModel {
  final String username;
  final String phoneNumber;
  final String email;
  final String password;

  const UserModel({
    required this.username,
    required this.phoneNumber,
    required this.email,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
    };
  }

  UserModel copyWith({
    String? username,
    String? phoneNumber,
    String? email,
    String? password,
  }) {
    return UserModel(
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}