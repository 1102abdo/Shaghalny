class Worker {
  final int id;
  final String name;
  final String email;
  final String job;
  final bool banned;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Worker({
    required this.id,
    required this.name,
    required this.email,
    required this.job,
    required this.banned,
    this.createdAt,
    this.updatedAt,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      job: json['job'] ?? '',
      banned: json['ban'] == '1' || json['ban'] == 1 || json['ban'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'job': job,
      'ban': banned ? '1' : '0',
    };
  }
}
