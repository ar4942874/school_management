import 'package:riverpod/riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_management/admin_side/features/staff_attandenace.dart/model/staff_attendance.dart';


class AttendanceNotifier extends StateNotifier<List<StaffAttendanceModel>> {
  AttendanceNotifier() : super([]);

  final CollectionReference _attendanceCollection =
      FirebaseFirestore.instance.collection('staffAttendance');

  Future<void> fetchAttendance(String date) async {
    try {
      final snapshot = await _attendanceCollection
          .where('date', isEqualTo: date)
          .get();

      final attendanceList = snapshot.docs.map((doc) {
        return StaffAttendanceModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      state = attendanceList;
    } catch (e) {
      state = [];
      throw Exception('Error fetching attendance: $e');
    }
  }

  Future<void> updateAttendance(String staffId, bool status, String date) async {
    final attendanceDocId = "$staffId-$date";

    try {
      await _attendanceCollection.doc(attendanceDocId).set({
        'staffId': staffId,
        'attendanceMarked': status,
        'date': date,
        'time': status ? Timestamp.now() : null,
      });
      fetchAttendance(date); // Refresh attendance
    } catch (e) {
      throw Exception('Error updating attendance: $e');
    }
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, List<StaffAttendanceModel>>(
  (ref) => AttendanceNotifier(),
);
