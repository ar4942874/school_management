import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_management/admin_side/components/components.dart';

// Providers for text controllers and selected date
final studentNameControllerProvider =
    Provider((ref) => TextEditingController());
final fatherNameControllerProvider = Provider((ref) => TextEditingController());
final fatherPhoneControllerProvider =
    Provider((ref) => TextEditingController());
final motherNameControllerProvider = Provider((ref) => TextEditingController());
final genderControllerProvider = Provider((ref) => TextEditingController());
final cnicControllerProvider = Provider((ref) => TextEditingController());
final rollNoControllerProvider = Provider((ref) => TextEditingController());
final addressControllerProvider = Provider((ref) => TextEditingController());

final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

class AddStudent extends StatelessWidget {
  const AddStudent({super.key});
  static const String pageName = 'Add-Student';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight;
          return SingleChildScrollView(
            child: AddStudentView(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
          );
        },
      ),
    );
  }
}
