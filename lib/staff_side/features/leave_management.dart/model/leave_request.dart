class LeaveRequest {
  final String id;
  final DateTime date; // Use DateTime for better manipulation
  final String reason;
  final String status;

  LeaveRequest({
    required this.id,
    required this.date,
    required this.reason,
    required this.status,
  });

  // Factory constructor to create a LeaveRequest object from Firestore
  factory LeaveRequest.fromFirestore(Map<String, dynamic> data, String id) {
    return LeaveRequest(
      id: id,
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
      reason: data['reason'] ?? 'No reason provided',
      status: data['status'] ?? 'Pending',
    );
  }

  // Convert LeaveRequest object to Firestore-compatible Map
  Map<String, dynamic> toFirestore() {
    return {
      'date': date.toIso8601String(),
      'reason': reason,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(), // Include a timestamp for ordering
    };
  }
}
