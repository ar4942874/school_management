import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:school_management/admin_side/screens/add_staff.dart';
import 'package:school_management/admin_side/screens/add_student.dart';
import 'package:school_management/admin_side/features/auth/controller/firebase_auth_notifier.dart';
import 'package:school_management/models/student.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

final studentsCountProvider = FutureProvider<int>((ref) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    // Fetch all documents from the flat 'students' collection
    final studentsSnapshot = await firestore.collection('students').get();

    // The total count of students is simply the number of documents
    return studentsSnapshot.docs.length;
  } catch (e) {
    // Log or handle the error
    rethrow; // Propagate the error to the UI or caller
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
    final noOfStudents = ref.watch(studentsCountProvider);
    final staffCountAsyncValue = ref.watch(staffCountProvider);

    return Column(
      children: [
        _buildHeader('Overview', 'Active'),
        noOfStudents.when(
          data: (data) =>
              _buildOverviewRow(Icons.people, 'Students', data.toString()),
          error: (error, stackTrace) =>
              _buildOverviewRow(Icons.people, 'Students', error.toString()),
          loading: () => _buildOverviewRow(Icons.people, 'Students', 'loading'),
        ),
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

class AttendanceSection extends StatefulWidget {
  final double maxHeight;
  final double maxWidth;

  const AttendanceSection({
    super.key,
    required this.maxHeight,
    required this.maxWidth,
  });

  @override
  _AttendanceSectionState createState() => _AttendanceSectionState();
}

class _AttendanceSectionState extends State<AttendanceSection> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  int totalPresent = 0;
  int totalAbsent = 0;

  // Fetch attendance data for all students across classes on the selected date
  Future<void> fetchAttendance(DateTime date) async {
    setState(() {
      isLoading = true;
      totalPresent = 0;
      totalAbsent = 0;
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    try {
      // Query attendance records for the selected date
      final attendanceSnapshot = await firestore
          .collection('attendance')
          .where('date', isEqualTo: formattedDate)
          .get();

      // Count present and absent statuses
      for (var doc in attendanceSnapshot.docs) {
        final attendanceData = doc.data();
        if (attendanceData['isPresent'] == true) {
          totalPresent++;
        } else {
          totalAbsent++;
        }
      }
    } catch (e) {
      print('Error fetching attendance: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  // Open the date picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchAttendance(selectedDate);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAttendance(
        selectedDate); // Fetch attendance for the current date initially
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      width: widget.maxWidth,
      height: widget.maxHeight,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Title and Date Picker
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance Summary',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                ElevatedButton.icon(
                  onPressed: () => selectDate(context),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                ),
              ],
            ),
          ),

          // Bar Chart
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 1:
                                  return const Text('Present');
                                case 2:
                                  return const Text('Absent');
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toInt().toString());
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      barGroups: [
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: totalPresent.toDouble(),
                              color: Colors.green,
                              width: 10,
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: totalAbsent.toDouble(),
                              color: Colors.red,
                              width: 10,
                            ),
                          ],
                        ),
                      ],
                      minY: 0,
                      maxY: (totalPresent + totalAbsent).toDouble(),
                    ),
                  ),
          ),

          // Summary
          const SizedBox(height: 16),
          Text(
            'Total Students: ${totalPresent + totalAbsent}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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

class AddStudentView extends StatelessWidget {
  final double maxWidth;
  final double maxHeight;
  final String className;

  const AddStudentView(
      {super.key,
      required this.maxWidth,
      required this.maxHeight,
      required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Add Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: AddStudentForm(
            className: className,
          ),
        ),
      ),
    );
  }
}

class AddStudentForm extends StatefulWidget {
  const AddStudentForm({super.key, required this.className});
  final String className;

  @override
  _AddStudentFormState createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

//updating image to supabase
  Future<String?> _uploadImageToSupabase(File imageFile) async {
    try {
      final supabaseClient = Supabase.instance.client;

      // Define a unique file path in Supabase storage
      String filePath = 'students/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Perform the upload and expect a String response
      final response = await supabaseClient.storage
          .from('student_images') // Make sure this bucket exists in Supabase
          .uploadBinary(filePath, await imageFile.readAsBytes());
      // Assuming response is the file path on successful upload
      if (response.contains('error')) {
        print('Error uploading to Supabase: $response');
        return null;
      }

      // Generate the public URL of the uploaded image if successful
      final imageUrl = supabaseClient.storage
          .from('student_images')
          //i made change here removed data
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      print('Exception during upload: $e');
      return null;
    }
  }

  Future<void> _submitForm(
    TextEditingController studentNameController,
    TextEditingController rollNoController,
    TextEditingController addressController,
    TextEditingController classNameController,
    TextEditingController fatherNameController,
    TextEditingController fatherPhoneController,
    TextEditingController motherNameController,
    TextEditingController genderController,
    TextEditingController cnicController,
    DateTime? selectedDate,
    WidgetRef ref,
  ) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      // Upload image to Supabase
      String? imageURL;
      if (_selectedImage != null) {
        imageURL = await _uploadImageToSupabase(_selectedImage!);
      }

      // Prepare student data
      Student student = Student(
        name: studentNameController.text,
        address: addressController.text,
        className: classNameController.text,
        cnic: cnicController.text,
        createdAt: DateTime.now().toString(),
        dateOfBirth: selectedDate?.toIso8601String(),
        fatherName: fatherNameController.text,
        fatherPhone: fatherPhoneController.text,
        gender: genderController.text,
        motherName: motherNameController.text,
        studentPic: imageURL,
        rollNo: rollNoController.text,
      );

      // Store student data in Firestore
      await ref
          .read(firebaseAuthNotifierProvider.notifier)
          .storeStudentData(student.toMap());
      setState(() {
        _isUploading = false;
      });

      // Reset the form after submission
      _resetForm(
      studentNameController,
      rollNoController,
      addressController,
      classNameController,
      fatherNameController,
      fatherPhoneController,
      motherNameController,
      genderController,
      cnicController,
      ref,
    );
       
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student added successfully!'),
        ),
      );
    }
  }

 void _resetForm(
  TextEditingController studentNameController,
  TextEditingController rollNoController,
  TextEditingController addressController,
  TextEditingController classNameController,
  TextEditingController fatherNameController,
  TextEditingController fatherPhoneController,
  TextEditingController motherNameController,
  TextEditingController genderController,
  TextEditingController cnicController,
  WidgetRef ref,
) {
  // Clear all controllers
  studentNameController.clear();
  rollNoController.clear();
  addressController.clear();
  classNameController.clear();
  fatherNameController.clear();
  fatherPhoneController.clear();
  motherNameController.clear();
  genderController.clear();
  cnicController.clear();

  // Reset any other state
  _selectedImage = null; // Clear selected image
  ref.read(selectedDateProvider.notifier).state = null; // Reset selected date
}

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final studentNameController = ref.watch(studentNameControllerProvider);
        final rollNoController = ref.watch(rollNoControllerProvider);
        final addressController = ref.watch(addressControllerProvider);
        final classNameController = ref.watch(classNameProvider);
        final fatherNameController = ref.watch(fatherNameControllerProvider);
        final fatherPhoneController = ref.watch(fatherPhoneControllerProvider);
        final motherNameController = ref.watch(motherNameControllerProvider);
        final genderController = ref.watch(genderControllerProvider);
        final cnicController = ref.watch(cnicControllerProvider);
        final selectedDate = ref.watch(selectedDateProvider);

        if (widget.className.isNotEmpty) {
          classNameController.text = widget.className;
        }
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : null,
                    child: _selectedImage == null
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextFormField(
                controller: studentNameController,
                labelText: 'Enter Student Name',
                validator: (value) =>
                    _validateRequiredField(value, "student's name"),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: rollNoController,
                labelText: 'Enter Roll Number',
                validator: (value) =>
                    _validateRequiredField(value, 'roll number'),
              ),
              const SizedBox(height: 16),
              _buildDatePicker(context, ref, selectedDate),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: classNameController,
                labelText: "Class",
                enabled: widget.className.isEmpty,
                validator: (value) =>
                    _validateRequiredField(value, 'class name'),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: fatherNameController,
                labelText: "Enter Father's Name",
                validator: (value) =>
                    _validateRequiredField(value, "father's name"),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: fatherPhoneController,
                labelText: "Enter Father's Phone Number",
                keyboardType: TextInputType.phone,
                validator: (value) => _validatePhone(value),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: motherNameController,
                labelText: "Enter Mother's Name",
                validator: (value) =>
                    _validateRequiredField(value, "mother's name"),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: genderController,
                labelText: 'Enter Gender',
                validator: (value) => _validateRequiredField(value, 'gender'),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: cnicController,
                labelText: 'Enter CNIC Number',
                keyboardType: TextInputType.number,
                validator: (value) => _validateCNIC(value),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: addressController,
                labelText: 'Enter Address',
                validator: (value) => _validateRequiredField(value, 'address'),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: _isUploading
                      ? null
                      : () => _submitForm(
                          studentNameController,
                          rollNoController,
                          addressController,
                          classNameController,
                          fatherNameController,
                          fatherPhoneController,
                          motherNameController,
                          genderController,
                          cnicController,
                          selectedDate,
                          ref),
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Additional helper methods here (e.g., _buildTextFormField, _buildDatePicker, validation)
}

Widget _buildTextFormField({
  required TextEditingController controller,
  required String labelText,
  bool enabled = true,
  TextInputType keyboardType = TextInputType.text,
  required String? Function(String?) validator,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      enabled: enabled,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    validator: validator,
    keyboardType: keyboardType,
  );
}

Widget _buildDatePicker(
    BuildContext context, WidgetRef ref, DateTime? selectedDate) {
  return GestureDetector(
    onTap: () async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(1990),
        lastDate: DateTime.now(),
      );
      if (pickedDate != null) {
        ref.read(selectedDateProvider.notifier).state = pickedDate;
      }
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: 'Select Date of Birth',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
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

// Validation functions
String? _validateRequiredField(String? value, String fieldName) {
  return (value == null || value.isEmpty)
      ? 'Please enter the $fieldName'
      : null;
}

String? _validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the father\'s phone number';
  } else if (!RegExp(r'^\d{11}$').hasMatch(value)) {
    return 'Please enter a valid phone number';
  }
  return null;
}

String? _validateCNIC(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the CNIC number';
  } else if (!RegExp(r'^\d{13}$').hasMatch(value)) {
    return 'Please enter a valid CNIC number without dashes';
  }
  return null;
}
