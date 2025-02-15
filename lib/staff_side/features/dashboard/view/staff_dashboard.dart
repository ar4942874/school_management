import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_management/admin_side/features/auth/controller/firebase_auth_notifier.dart';
import 'package:school_management/admin_side/features/student_management/view/add_student.dart';
import 'package:school_management/staff_side/components/staff_components.dart';
import 'package:school_management/staff_side/features/dashboard/controller/staff_controller.dart';
import 'package:school_management/staff_side/features/leave_management.dart/view/leave_management_page.dart';
import 'package:school_management/staff_side/features/staff_attendance_management/view/staff_attendance_view.dart';
import 'package:school_management/staff_side/screens/students_data_display.dart';
import 'package:school_management/widgets/custom_loading_screen.dart';

class StaffDashboard extends ConsumerWidget {
  const StaffDashboard({super.key});
  static const String pageName = '/staff-dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Listen to the staffDataProvider
    final staffDataAsync = ref.watch(staffDataProvider);

    return staffDataAsync.when(
      data: (staffData) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              SizedBox(
                width: screenWidth,
                height: screenHeight * 0.4,
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        color: Colors.blue,
                      ),
                      width: screenWidth,
                      height: screenHeight * 0.3,
                    ),
                    Positioned(
                      left: screenWidth * 0.05,
                      bottom: 0,
                      child: StaffProfile(
                        width: screenWidth * 0.9,
                        height: screenHeight * 0.25,
                        imageUrl:
                            'https://images.unsplash.com/photo-1576158113928-4c240eaaf360?w=600&auto=format&fit=crop&q=60',
                        name: staffData.staffName,
                        className: staffData.staffClass,
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.05,
                      child: SizedBox(
                        width: screenWidth,
                        height: screenHeight * 0.08,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      title: const Text(
                                        'Do you want to sign out?',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            ref
                                                .read(
                                                    firebaseAuthNotifierProvider
                                                        .notifier)
                                                .signOut();
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Yes'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('No'),
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.arrow_back_ios),
                            ),
                            const SizedBox(width: 70),
                            const Text(
                              'Staff Dashboard',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 50),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StaffFeatures(
                    title: 'Mark Your Attendance',
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    icon: const Icon(Icons.fact_check_outlined, size: 50),
                    onTap: () {
                      Navigator.of(context).pushNamed(StaffAttendanceView.pageName);
                    },
                  ),
                  StaffFeatures(
                    title: 'Student Attendance',
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    icon: const Icon(Icons.fact_check_outlined, size: 50),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AttendancePage.pageName,
                        arguments: staffData.staffClass,
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StaffFeatures(
                    title: 'Add Student',
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    icon: const Icon(Icons.person),
                    onTap: () {
                      Navigator.of(ref.context).pushNamed(AddStudent.pageName);
                    },
                  ),
                  StaffFeatures(
                    title: 'Request for Leave',
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    icon: const Icon(Icons.request_page),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(LeaveManagementPage.pageName);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CustomLoadingScreen()),
      error: (error, _) => Center(
        child: Text('Error: ${error.toString()}'),
      ),
    );
  }
}
