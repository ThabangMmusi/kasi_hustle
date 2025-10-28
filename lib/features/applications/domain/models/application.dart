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
}
