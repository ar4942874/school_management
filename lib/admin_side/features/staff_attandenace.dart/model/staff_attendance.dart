class StaffAttendanceModel {
  final String staffId;
  final bool attendanceMarked;
  final String date;
  final String? time;

  StaffAttendanceModel({
    required this.staffId,
    required this.attendanceMarked,
    required this.date,
    this.time,
  });

  factory StaffAttendanceModel.fromMap(Map<String, dynamic> map) {
    return StaffAttendanceModel(
      staffId: map['staffId'],
      attendanceMarked: map['attendanceMarked'],
      date: map['date'],
      time: map['time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'attendanceMarked': attendanceMarked,
      'date': date,
      'time': time,
    };
  }
}
