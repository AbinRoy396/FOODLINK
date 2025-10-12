class UserModel {
  final int id;
  final String email;
  final String name;
  final String role;
  final String? address;
  final String createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.address,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] ?? json['id'], // Support both field names
      email: json['email'],
      name: json['name'],
      role: json['role'],
      address: json['address'],
      createdAt: json['createdat'] ?? json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'address': address,
    'createdAt': createdAt,
  };
}