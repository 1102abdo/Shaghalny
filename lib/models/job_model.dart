class Job {
  final int id;
  final String title;
  final String description;
  final int numWorkers;
  final double salary;
  final String type;
  final String location;
  final String? picture;
  final int usersId;
  final String? userName;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.numWorkers,
    required this.salary,
    required this.type,
    required this.location,
    this.picture,
    required this.usersId,
    this.userName,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // Parse salary with improved error handling
    double parseSalary(dynamic salaryValue) {
      if (salaryValue == null) return 0.0;
      if (salaryValue is int) return salaryValue.toDouble();
      if (salaryValue is double) return salaryValue;

      // Handle string values
      if (salaryValue is String) {
        try {
          // Clean the string (remove any non-numeric characters except decimal point)
          final cleanSalary = salaryValue.replaceAll(RegExp(r'[^\d.]'), '');
          if (cleanSalary.isEmpty) return 0.0;
          return double.parse(cleanSalary);
        } catch (e) {
          print('Error parsing salary: $e');
          return 0.0;
        }
      }

      // Default fallback
      return 0.0;
    }

    return Job(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      numWorkers: json['num_workers'] ?? 1,
      salary: parseSalary(json['salary']),
      type: json['type'] ?? 'full-time',
      location: json['location'] ?? 'Unknown',
      picture: json['picture'],
      usersId: json['users_id'],
      userName: json['name'], // From user relationship
      status: json['status'],
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
    final Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'description': description,
      'num_workers': numWorkers,
      'salary': salary,
      'type': type,
      'location': location,
      'picture': picture,
      'users_id': usersId,
      'name': userName,
    };

    // Only include status if it's not null
    if (status != null) {
      data['status'] = status;
    }

    return data;
  }
}
