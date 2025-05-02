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
    this.createdAt,
    this.updatedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      numWorkers: json['num_workers'] ?? 1,
      salary:
          (json['salary'] is int)
              ? json['salary'].toDouble()
              : double.parse(json['salary'].toString()),
      type: json['type'] ?? 'full-time',
      location: json['location'] ?? 'Unknown',
      picture: json['picture'],
      usersId: json['users_id'],
      userName: json['name'], // From user relationship
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
      'title': title,
      'description': description,
      'num_workers': numWorkers,
      'salary': salary,
      'type': type,
      'location': location,
      'picture': picture,
      'users_id': usersId,
    };
  }
}
