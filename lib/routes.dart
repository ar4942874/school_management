import 'package:flutter/material.dart';
import 'package:school_management/admin_side/screens/add_staff.dart';
import 'package:school_management/admin_side/screens/add_student.dart';
import 'package:school_management/admin_side/screens/admin_dashboard.dart';
import 'package:school_management/staff_side/features/leave_management.dart/view/leave_management_page.dart';
import 'package:school_management/staff_side/features/staff_attendance_management/view/staff_attendance_view.dart';
import 'package:school_management/staff_side/features/dashboard/view/staff_dashboard.dart';
import 'package:school_management/staff_side/screens/students_data_display.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  return switch (settings.name) {
    AdminDashboard.pageName => MaterialPageRoute(
        builder: (context) => const AdminDashboard(),
      ),
    AddStaff.pageName => MaterialPageRoute(
        builder: (context) => const AddStaff(),
      ),
    AddStudent.pageName => MaterialPageRoute(
        builder: (context) => const AddStudent(),
      ),
    AttendancePage.pageName => MaterialPageRoute(
        builder: (context) {
          String className = settings.arguments as String;
          return AttendancePage(className: className);
        },
      ),
    StaffDashboard.pageName => MaterialPageRoute(
        builder: (context) => const StaffDashboard(),
      ),
    LeaveManagementPage.pageName => MaterialPageRoute(
        builder: (context) => const LeaveManagementPage(),
      ),
    StaffAttendanceView.pageName => MaterialPageRoute(
        builder: (context) => const StaffAttendanceView(officeLatitude: 29.3828388,officeLongitude: 71.7158160,),
      ),
    _ => MaterialPageRoute(
        builder: (context) => const AdminDashboard(),
      )
  };
}
