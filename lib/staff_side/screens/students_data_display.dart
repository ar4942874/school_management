import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_management/models/student.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  static const String pageName = '/student-attendance-page';
  final String className;

  const AttendancePage({super.key, required this.className});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final cutoffTime =
      const TimeOfDay(hour: 09, minute: 0); // Set attendance cutoff time
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Check if the current time is before the cutoff time
  bool _canMarkAttendance() {
    final now = TimeOfDay.now();
    return now.hour < cutoffTime.hour ||
        (now.hour == cutoffTime.hour && now.minute < cutoffTime.minute);
  }

  // Toggle attendance status
  Future<void> toggleAttendance(
      String className, String rollNo, bool currentStatus) async {
    if (_canMarkAttendance()) {
      final documentId = '${className}_${currentDate}_$rollNo';
      await firestore.collection('attendance').doc(documentId).set({
        'className': className,
        'date': currentDate,
        'rollNo': rollNo,
        'isPresent': !currentStatus,
      }, SetOptions(merge: true));
    } else {
      // Show message if trying to mark attendance after cutoff time
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Attendance can only be marked before ${cutoffTime.format(context)}.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('students')
            .where('className', isEqualTo: widget.className)
            .snapshots(),
        builder: (context, studentSnapshot) {
          if (studentSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!studentSnapshot.hasData || studentSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          final students = studentSnapshot.data!.docs.map((doc) {
            return Student.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final documentId =
                  '${widget.className}_${currentDate}_${student.rollNo}';

              return StreamBuilder<DocumentSnapshot>(
                stream: firestore
                    .collection('attendance')
                    .doc(documentId)
                    .snapshots(),
                builder: (context, attendanceSnapshot) {
                  if (attendanceSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  bool isPresent = attendanceSnapshot.hasData &&
                          attendanceSnapshot.data!.data() != null &&
                          (attendanceSnapshot.data!.data()
                                  as Map<String, dynamic>)
                              .containsKey('isPresent')
                      ? attendanceSnapshot.data!.get('isPresent') as bool
                      : false;

                  return ListTile(
                    leading: student.studentPic != null
                        ? ClipOval(
                            child: Image.network(
                              student.studentPic!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person),
                            ),
                          )
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(student.name),
                    subtitle: Text('Roll No: ${student.rollNo}'),
                    trailing: Switch(
                      value: isPresent,
                      onChanged: (value) {
                        toggleAttendance(
                            widget.className, student.rollNo, isPresent);
                      },
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.grey,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
