import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/staff_attendance_controller.dart';

class StaffAttendanceView extends StatefulWidget {
  static const  String pageName='/Staff-Attendance';
  final double officeLatitude;
  final double officeLongitude;

  const StaffAttendanceView({
    Key? key,
    required this.officeLatitude,
    required this.officeLongitude,
  }) : super(key: key);

  @override
  _StaffAttendanceViewState createState() => _StaffAttendanceViewState();
}

class _StaffAttendanceViewState extends State<StaffAttendanceView> {
  final StaffAttendanceController _controller = StaffAttendanceController();

  Future<String> getStaffId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') ?? '';
  }

  Future<void> handleMarkAttendance() async {
    try {
      String staffId = await getStaffId();
      await _controller.markAttendance(
        staffId: staffId,
        targetLatitude: widget.officeLatitude,
        targetLongitude: widget.officeLongitude,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance marked successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Attendance'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: handleMarkAttendance,
          child: const Text('Mark Attendance'),
        ),
      ),
    );
  }
}
