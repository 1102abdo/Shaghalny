class User {
  final int id;
  final String name;
  final String email;
  final String company;
  final String? role;
  final bool banned;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.company,
    this.role,
    required this.banned,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      company: json['company'] ?? '',
      role: json['role'],
      banned: json['ban'] == '1' || json['ban'] == 1 || json['ban'] == true,
      emailVerifiedAt:
          json['email_verified_at'] != null
              ? DateTime.parse(json['email_verified_at'])
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'company': company,
      'role': role,
      'ban': banned ? '1' : '0',
    };
  }
}
