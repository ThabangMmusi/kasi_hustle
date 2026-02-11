class Application {
  final String id;
  final String jobId;
  final String jobTitle;
  final String jobDescription;
  final double budget;
  final String location;
  final double latitude;
  final double longitude;
  final String applicantId;
  final String applicantName;
  final String message;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime appliedAt;
  final String jobOwnerId;
  final String jobOwnerName;

  Application({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.jobDescription,
    required this.budget,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.applicantId,
    required this.applicantName,
    required this.message,
    required this.status,
    required this.appliedAt,
    required this.jobOwnerId,
    required this.jobOwnerName,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      jobId: json['job_id'],
      jobTitle: json['job_title'] ?? '',
      jobDescription: json['job_description'] ?? '',
      budget: json['budget']?.toDouble() ?? 0.0,
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      applicantId: json['applicant_id'],
      applicantName: json['applicant_name'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      appliedAt: DateTime.parse(
        json['applied_at'] ?? DateTime.now().toIso8601String(),
      ),
      jobOwnerId: json['job_owner_id'] ?? '',
      jobOwnerName: json['job_owner_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'job_title': jobTitle,
      'job_description': jobDescription,
      'budget': budget,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'applicant_id': applicantId,
      'applicant_name': applicantName,
      'message': message,
      'status': status,
      'applied_at': appliedAt.toIso8601String(),
      'job_owner_id': jobOwnerId,
      'job_owner_name': jobOwnerName,
    };
  }
}
