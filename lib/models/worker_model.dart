class Worker {
  final int? id;
  final String name;
  final String email;
  final String job;
  final bool banned;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? token;

  Worker({
    this.id,
    required this.name,
    required this.email,
    required this.job,
    required this.banned,
    this.createdAt,
    this.updatedAt,
    this.token,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    // Handle case when json has no 'id' field (during registration/login)
    // Try multiple possible ID field names
    int? workerId;

    if (json['id'] != null) {
      // Try to parse the ID value regardless of its type
      try {
        workerId =
            json['id'] is int ? json['id'] : int.parse(json['id'].toString());
      } catch (e) {
        print('Error parsing worker ID: $e');
      }
    } else if (json['workers_id'] != null) {
      try {
        workerId =
            json['workers_id'] is int
                ? json['workers_id']
                : int.parse(json['workers_id'].toString());
      } catch (e) {
        print('Error parsing workers_id: $e');
      }
    } else if (json['worker_id'] != null) {
      try {
        workerId =
            json['worker_id'] is int
                ? json['worker_id']
                : int.parse(json['worker_id'].toString());
      } catch (e) {
        print('Error parsing worker_id: $e');
      }
    }

    // If we still have no ID but have an email, generate a deterministic ID based on email
    if (workerId == null && json['email'] != null) {
      // Create a simple hash of the email
      final emailStr = json['email'].toString();
      workerId = emailStr.codeUnits.fold<int>(
        0,
        (prev, element) => prev + element,
      );
      print('Generated worker ID from email hash: $workerId');
    }

    return Worker(
      id: workerId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      job: json['job'] ?? '',
      banned: json['ban'] == '1' || json['ban'] == 1 || json['ban'] == true,
      token: json['token'],
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
      'job': job,
      'ban': banned ? '1' : '0',
      'token': token,
    };
  }
}
