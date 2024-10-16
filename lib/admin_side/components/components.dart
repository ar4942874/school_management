import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:school_management/admin_side/screens/add_staff.dart';
import 'package:school_management/admin_side/screens/add_student.dart';
import 'package:school_management/admin_side/providers/firebase_auth_notifier.dart';

final isTappedProvider = StateProvider<bool>((ref) => false);

final staffCountProvider = StreamProvider<int>((ref) {
  final firebaseAuthNotifier = ref.watch(firebaseAuthNotifierProvider);
  final firestore = FirebaseFirestore.instance;

  if (firebaseAuthNotifier != null) {
    // Admin ke UID ke hisaab se staff count stream ko listen karna
    return firestore
        .collection('staff')
        .where('adminId', isEqualTo: firebaseAuthNotifier.uid)
        .snapshots()
        .map((snapshot) => snapshot.size); // Snapshot ke size ko return karega
  } else {
    // Agar admin sign in nahi hai to empty stream return karega jo 0 emit karegi
    return Stream.value(0);
  }
});

class OverviewSection extends ConsumerWidget {
  const OverviewSection({
    super.key,
    required this.maxWidth,
    required this.maxHeight,
  });

  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffCountAsyncValue = ref.watch(staffCountProvider);

    return Column(
      children: [
        _buildHeader('Overview', 'Active'),
        _buildOverviewRow(Icons.people, 'Students', '0'),
        _buildOverviewRow(Icons.flag, 'Classes', '10'),
        staffCountAsyncValue.when(
          data: (staffCount) => _buildOverviewRow(
              FontAwesomeIcons.peopleGroup, 'Staff', staffCount.toString()),
          loading: () => _buildOverviewRow(
              FontAwesomeIcons.peopleGroup, 'Staff', 'Loading...'),
          error: (error, stackTrace) =>
              _buildOverviewRow(FontAwesomeIcons.peopleGroup, 'Staff', 'Error'),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, String status) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: maxWidth,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
            color: const Color.fromARGB(255, 133, 125, 125).withOpacity(0.1)),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            Text(status, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: maxWidth,
        height: 50,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.1))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(icon),
                ),
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(
              width: 65,
              child: AutoSizeText(
                value,
                maxLines: 1,
                textAlign: TextAlign.center,
                maxFontSize: 18,
                minFontSize: 10,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceSection extends StatelessWidget {
  const AttendanceSection({
    super.key,
    required this.maxHeight,
    required this.maxWidth,
  });

  final double maxHeight;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    // Define your attendance data as a list of BarChartGroupData
    List<BarChartGroupData> attendanceData = [
      BarChartGroupData(x: 1, barRods: [
        BarChartRodData(
          toY: 10,
          color: Colors.blue,
          width: 15,
        ),
      ]),
      BarChartGroupData(x: 2, barRods: [
        BarChartRodData(
          toY: 20,
          color: Colors.blue,
          width: 15,
        ),
      ]),
      BarChartGroupData(x: 3, barRods: [
        BarChartRodData(
          toY: 15,
          color: Colors.blue,
          width: 15,
        ),
      ]),
      BarChartGroupData(x: 4, barRods: [
        BarChartRodData(
          toY: 25,
          color: Colors.blue,
          width: 15,
        ),
      ]),
      BarChartGroupData(x: 5, barRods: [
        BarChartRodData(
          toY: 30,
          color: Colors.blue,
          width: 15,
        ),
      ]),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      width: maxWidth,
      height: maxHeight,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Attendance Summary',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: true),
                titlesData: const FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                barGroups: attendanceData,
                minY: 0,
                maxY: 30, // Adjust this value as needed
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFloatingActionButton extends ConsumerWidget {
  const CustomFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTapped = ref.watch(isTappedProvider);

    return GestureDetector(
      onTap: () => ref.read(isTappedProvider.notifier).state = !isTapped,
      child: AnimatedContainer(
        width: isTapped ? 170 : 50,
        height: isTapped ? 200 : 50,
        duration: const Duration(milliseconds: 300),
        child: isTapped ? _buildExpandedFab(ref) : _buildCollapsedFab(),
      ),
    );
  }

  Widget _buildCollapsedFab() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.add, color: Colors.black),
    );
  }

  Widget _buildExpandedFab(WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.amber, borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFabItem('Add Student', Icons.person_add_alt_1, () {
            Navigator.of(ref.context).pushNamed(AddStudent.pageName);
          }),
          _buildFabItem('Add Staff', Icons.person_add_alt_1, () {
            Navigator.of(ref.context).pushNamed(AddStaff.pageName);
          }),
          _buildFabItem('Add Class', Icons.people_alt, () {}),
          _buildFabItem('Close', Icons.close,
              () => ref.read(isTappedProvider.notifier).state = false,
              color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildFabItem(String label, IconData icon, VoidCallback onTap,
      {Color color = Colors.black}) {
    return Expanded(
      flex: 2,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(left: 15),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Icon(icon, color: color),
              ),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: color, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSteppers extends StatelessWidget {
  const CustomSteppers({
    super.key,
    required this.backgroundColor,
    required this.currentStep,
  });

  final int currentStep;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final stepCircleSize = availableWidth * 0.10;
        final lineLength = availableWidth * 0.1;
        final fontSize = stepCircleSize * 0.3;

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStepColumn(
                    color: _getStepColor(0),
                    circleSize: stepCircleSize,
                    fontSize: fontSize,
                    step: '1',
                    label: 'Basic Info',
                    currentStep: currentStep,
                    stepIndex: 0,
                  ),
                  _buildLine(_getStepColor(1), lineLength, stepCircleSize),
                  _buildStepColumn(
                    color: _getStepColor(1),
                    circleSize: stepCircleSize,
                    fontSize: fontSize,
                    step: '2',
                    label: 'Contact Info',
                    currentStep: currentStep,
                    stepIndex: 1,
                  ),
                  _buildLine(_getStepColor(2), lineLength, stepCircleSize),
                  _buildStepColumn(
                    color: _getStepColor(2),
                    circleSize: stepCircleSize,
                    fontSize: fontSize,
                    step: '3',
                    label: 'Institute Info',
                    currentStep: currentStep,
                    stepIndex: 2,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStepColor(int step) {
    return currentStep >= step ? Colors.amber : Colors.grey;
  }

  Widget _buildStepColumn({
    required Color color,
    required double circleSize,
    required double fontSize,
    required String step,
    required String label,
    required int currentStep,
    required int stepIndex,
  }) {
    return Column(
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: color,
            ),
            shape: BoxShape.circle,
          ),
          child: currentStep > stepIndex
              ? Icon(Icons.done, color: Colors.black, size: fontSize * 1.5)
              : Center(
                  child: Text(
                    step,
                    style: TextStyle(fontSize: fontSize, color: color),
                  ),
                ),
        ),
        SizedBox(height: fontSize * 0.5),
        Text(
          label,
          style: TextStyle(fontSize: fontSize * 0.8, color: color),
        ),
      ],
    );
  }

  Widget _buildLine(
    Color color,
    double lineLength,
    double stepCircleSize,
  ) {
    return Container(
      width: lineLength * 2,
      height: 3.5,
      margin: const EdgeInsets.only(bottom: 15),
      color: color,
    );
  }
}

class BasicInfo extends StatelessWidget {
  const BasicInfo({
    super.key,
    required this.maxWidth,
    required this.maxHeight,
    required this.joinDateController,
    required this.staffNameController,
    required this.genderController,
  });

  final double maxWidth;
  final double maxHeight;
  final TextEditingController joinDateController;
  final TextEditingController staffNameController;
  final TextEditingController genderController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: maxWidth * 0.4,
          height: maxHeight * 0.3,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amberAccent,
          ),
        ),
        SizedBox(
          width: maxWidth,
          child: TextFormField(
            controller: staffNameController,
            decoration: const InputDecoration(
              label: Text('Staff Name'),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the staff name';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: SizedBox(
            width: maxWidth,
            child: TextFormField(
              controller: joinDateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: const InputDecoration(
                label: Text('Join Date'),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a join date';
                }
                return null;
              },
            ),
          ),
        ),
        SizedBox(
          width: maxWidth,
          child: TextFormField(
            controller: genderController,
            decoration: const InputDecoration(
              label: Text('Gender'),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the gender';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      joinDateController.text = "${selectedDate.toLocal()}".split(' ')[0];
    }
  }
}

class ContactInfo extends StatelessWidget {
  const ContactInfo({
    super.key,
    required this.maxWidth,
    required this.maxHeight,
    required this.textNumberController,
    required this.whatsAppController,
    required this.addressController,
  });

  final double maxWidth;
  final double maxHeight;
  final TextEditingController textNumberController;
  final TextEditingController whatsAppController;
  final TextEditingController addressController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          width: maxWidth,
          child: TextFormField(
            keyboardType: TextInputType.phone,
            controller: textNumberController,
            decoration: const InputDecoration(
              label: Text('Text Number'),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a text number';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: SizedBox(
            width: maxWidth,
            child: TextFormField(
              keyboardType: TextInputType.phone,
              controller: whatsAppController,
              decoration: const InputDecoration(
                label: Text('WhatsApp'),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a WhatsApp number';
                }
                return null;
              },
            ),
          ),
        ),
        SizedBox(
          width: maxWidth,
          child: TextFormField(
            controller: addressController,
            decoration: const InputDecoration(
              label: Text('Address'),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the address';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

class InstituteInfo extends StatelessWidget {
  const InstituteInfo({
    super.key,
    required this.maxWidth,
    required this.maxHeight,
    required this.idController,
    required this.passwordController,
    required this.classController,
    required this.salaryController,
    required this.qualificationController,
  });

  final double maxWidth;
  final double maxHeight;
  final TextEditingController idController;
  final TextEditingController passwordController;
  final TextEditingController classController;
  final TextEditingController salaryController;
  final TextEditingController qualificationController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          width: maxWidth,
          child: TextFormField(
            controller: idController,
            decoration: const InputDecoration(
              label: Text('ID'),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the ID';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: SizedBox(
            width: maxWidth,
            child: TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                label: Text('Password'),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the password';
                }
                return null;
              },
            ),
          ),
        ),
        SizedBox(
          width: maxWidth,
          child: TextFormField(
            controller: classController,
            decoration: const InputDecoration(
              label: Text('Class'),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the class';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: SizedBox(
            width: maxWidth,
            child: TextFormField(
              controller: salaryController,
              decoration: const InputDecoration(
                label: Text('Salary'),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the salary';
                }
                return null;
              },
            ),
          ),
        ),
        SizedBox(
          width: maxWidth,
          child: TextFormField(
            controller: qualificationController,
            decoration: const InputDecoration(
              label: Text('Qualification'),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the qualification';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

// class AddStudentView extends ConsumerWidget {
//   const AddStudentView({
//     super.key,
//     required this.maxWidth,
//     required this.maxHeight,
//   });

//   final double maxWidth;
//   final double maxHeight;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final studentNameController = ref.watch(studentNameControllerProvider);
//     final fatherNameController = ref.watch(fatherNameControllerProvider);
//     final fatherPhoneController = ref.watch(fatherPhoneControllerProvider);
//     final motherNameController = ref.watch(motherNameControllerProvider);
//     final genderController = ref.watch(genderControllerProvider);
//     final cnicController = ref.watch(cnicControllerProvider);
//     final rollNoController = ref.watch(rollNoControllerProvider);
//     final addressController = ref.watch(addressControllerProvider);
//     final selectedDate = ref.watch(selectedDateProvider);

//     return Form(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: maxWidth * 0.3,
//             height: maxHeight * 0.2,
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.amber,
//             ),
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: maxWidth,
//             child: TextFormField(
//               controller: studentNameController,
//               decoration: const InputDecoration(
//                 label: Text('Enter Student Name'),
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter the student name';
//                 }
//                 return null;
//               },
//             ),
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: maxWidth,
//             child: TextFormField(
//               controller: rollNoController,
//               decoration: const InputDecoration(
//                 label: Text('Enter Roll No'),
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter the roll number';
//                 }
//                 return null;
//               },
//             ),
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: maxWidth,
//             child: GestureDetector(
//               onTap: () async {
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: selectedDate ?? DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime.now(),
//                 );
//                 if (pickedDate != null) {
//                   ref.read(selectedDateProvider.notifier).state = pickedDate;
//                 }
//               },
//               child: InputDecorator(
//                 decoration: const InputDecoration(
//                   labelText: 'Select Date of Birth',
//                   border: OutlineInputBorder(),
//                 ),
//                 child: Text(
//                   selectedDate != null
//                       ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
//                       : 'No date selected',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: maxWidth,
//             child: TextFormField(
//               controller: fatherNameController,
//               decoration: const InputDecoration(
//                 label: Text('Enter Father Name'),
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter the father\'s name';
//                 }
//                 return null;
//               },
//             ),
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: maxWidth,
//             child: TextFormField(
//               controller: fatherPhoneController,
//               decoration: const InputDecoration(
//                 label: Text('Enter Father Phone Number'),
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.phone,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter the father\'s phone number';
//                 }
//                 return null;
//               },
//             ),
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: maxWidth,
//             child: TextFormField(
//               controller: motherNameController,
//               decoration: const InputDecoration(
//                 label: Text('Enter Mother Name'),
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter the mother\'s name';
//                 }
//                 return null;
//               },
//             ),
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: maxWidth,
//             child: TextFormField(
//               controller: genderController,
//               decoration: const InputDecoration(
//                 label: Text('Enter Gender'),
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter the gender';
//                 }
//                 return null;
//               },
//             ),
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: maxWidth,
//             child: TextFormField(
//               controller: cnicController,
//               decoration: const InputDecoration(
//                 label: Text('Enter CNIC'),
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter the CNIC';
//                 }
//                 return null;
//               },
//             ),
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: maxWidth,
//             child: TextFormField(
//               controller: addressController,
//               decoration: const InputDecoration(
//                 label: Text('Enter Address'),
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter the address';
//                 }
//                 return null;
//               },
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               // Add your form submission logic here
//             },
//             child: const Text('Submit'),
//           ),
//         ],
//       ),
//     );
//   }
// }
class AddStudentView extends ConsumerWidget {
  const AddStudentView({
    super.key,
    required this.maxWidth,
    required this.maxHeight,
  });

  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Retrieve controllers and selected date from providers
    final studentNameController = ref.watch(studentNameControllerProvider);
    final fatherNameController = ref.watch(fatherNameControllerProvider);
    final fatherPhoneController = ref.watch(fatherPhoneControllerProvider);
    final motherNameController = ref.watch(motherNameControllerProvider);
    final genderController = ref.watch(genderControllerProvider);
    final cnicController = ref.watch(cnicControllerProvider);
    final rollNoController = ref.watch(rollNoControllerProvider);
    final addressController = ref.watch(addressControllerProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Add Student",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            buildTextFormField(studentNameController, 'Enter Student Name'),
            const SizedBox(height: 16),
            buildTextFormField(rollNoController, 'Enter Roll Number'),
            const SizedBox(height: 16),
            buildDatePicker(context, ref, selectedDate),
            const SizedBox(height: 16),
            buildTextFormField(fatherNameController, 'Enter Father\'s Name'),
            const SizedBox(height: 16),
            buildTextFormField(
                fatherPhoneController, 'Enter Father\'s Phone Number'),
            const SizedBox(height: 16),
            buildTextFormField(motherNameController, 'Enter Mother\'s Name'),
            const SizedBox(height: 16),
            buildTextFormField(genderController, 'Enter Gender'),
            const SizedBox(height: 16),
            buildTextFormField(cnicController, 'Enter CNIC Number'),
            const SizedBox(height: 16),
            buildTextFormField(addressController, 'Enter Address'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Collect data and call the storeStudentData method
                final studentData = {
                  'name': studentNameController.text,
                  'rollNo': rollNoController.text,
                  'dateOfBirth': selectedDate?.toIso8601String(),
                  'fatherName': fatherNameController.text,
                  'fatherPhone': fatherPhoneController.text,
                  'motherName': motherNameController.text,
                  'gender': genderController.text,
                  'cnic': cnicController.text,
                  'address': addressController.text,
                  'createdAt': DateTime.now().toIso8601String(),
                };

                var success = ref
                    .read(firebaseAuthNotifierProvider.notifier)
                    .storeStudentData(studentData);
                // if(success){}
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build text form fields
  Widget buildTextFormField(
      TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }

  // Function to build date picker
  Widget buildDatePicker(
      BuildContext context, WidgetRef ref, DateTime? selectedDate) {
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          ref.read(selectedDateProvider.notifier).state = pickedDate;
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Select Date of Birth',
          border: OutlineInputBorder(),
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(selectedDate)
              : 'Please select a date',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
