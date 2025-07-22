class Issue {
  final String id;
  final String username; 
  final String bookboxId;
  final String subject;
  final String description;
  final String status; 
  final DateTime reportedAt;
  final DateTime? resolvedAt;

  Issue({
    required this.id,
    required this.username,
    required this.bookboxId,
    required this.subject,
    required this.description,
    required this.status,
    required this.reportedAt,
    this.resolvedAt,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'],
      username: json['username'],
      bookboxId: json['bookboxId'],
      subject: json['subject'],
      description: json['description'],
      status: json['status'],
      reportedAt: DateTime.parse(json['reportedAt']),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
    );
  }
}