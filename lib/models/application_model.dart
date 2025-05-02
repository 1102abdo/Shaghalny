class Application {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String experience;
  final String skills;
  final String? cv;
  final bool binned;
  final int jobsId;
  final int workersId;
  final String? jobTitle;
  final String? workerName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Application({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.experience,
    required this.skills,
    this.cv,
    required this.binned,
    required this.jobsId,
    required this.workersId,
    this.jobTitle,
    this.workerName,
    this.createdAt,
    this.updatedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      experience: json['experience'] ?? '',
      skills: json['skills'] ?? '',
      cv: json['cv'],
      binned: json['bin'] == '1' || json['bin'] == 1 || json['bin'] == true,
      jobsId: json['jobs_id'],
      workersId: json['workers_id'],
      jobTitle: json['job_title'],
      workerName: json['worker_name'],
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
      'phone': phone,
      'experience': experience,
      'skills': skills,
      'cv': cv,
      'bin': binned ? '1' : '0',
      'jobs_id': jobsId,
      'workers_id': workersId,
    };
  }
}
