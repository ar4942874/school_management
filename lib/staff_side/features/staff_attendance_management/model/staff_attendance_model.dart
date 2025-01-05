import 'package:cloud_firestore/cloud_firestore.dart';

class StaffAttendance {
  final String staffId;
  final bool attendanceMarked;
  final String date;
  final String time;
  final DateTime timestamp;
  final Map<String, double> location;

  StaffAttendance({
    required this.staffId,
    required this.attendanceMarked,
    required this.date,
    required this.time,
    required this.timestamp,
    required this.location,
  });

  // Factory to create from Firestore data
  factory StaffAttendance.fromMap(Map<String, dynamic> map) {
    return StaffAttendance(
      staffId: map['staffId'] ?? '',
      attendanceMarked: map['attendanceMarked'] ?? false,
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      location: Map<String, double>.from(map['location']),
    );
  }

  // Convert to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'attendanceMarked': attendanceMarked,
      'date': date,
      'time': time,
      'timestamp': timestamp,
      'location': location,
    };
  }
}
