import 'package:flutter/material.dart';
import 'package:school_management/admin_side/screens/add_staff.dart';
import 'package:school_management/admin_side/screens/add_student.dart';
import 'package:school_management/admin_side/screens/admin_dashboard.dart';
import 'package:school_management/staff_side/screens/staff_dashboard.dart';

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
    StaffDashboard.pageName => MaterialPageRoute(
        builder: (context) => const StaffDashboard(),
      ),
    _ => MaterialPageRoute(
        builder: (context) => const AdminDashboard(),
      )
  };
}
