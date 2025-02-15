// Import necessary packages.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:school_management/admin_side/features/student_management/controller/student_controller.dart';
import 'package:school_management/admin_side/features/student_management/view/add_student.dart';
import 'package:school_management/admin_side/screens/student_tile.dart';
import 'package:school_management/admin_side/features/student_management/model/student.dart';

/// The StudentPage view displays the list of students and provides
/// search, filtering, deletion, and update functionalities.
/// This acts as the View in the MVC pattern.
class StudentPage extends ConsumerStatefulWidget {
  const StudentPage({super.key});
  static const String pageName = '/students-page';

  @override
  ConsumerState<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends ConsumerState<StudentPage> {
  // Controller for the search text field.
  final TextEditingController _searchController = TextEditingController();
  // Local variable to store the search query in lowercase.
  String _searchQuery = "";
  // Local variable to store the selected class filter (null means all classes).
  String? _selectedClass;

  /// Displays a confirmation dialog to delete a student record.
  void _showDeleteDialog(Student student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Dialog title.
          title: const Text("Delete Student"),
          // Dialog content showing which student's record will be deleted.
          content: Text(
            "Are you sure you want to delete ${student.name}'s record?",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            // 'No' button: dismisses the dialog.
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            // 'Yes' button: triggers deletion.
            TextButton(
              onPressed: () async {
                // Use the controller to delete the student.
                await ref
                    .read(studentControllerProvider)
                    .deleteStudent(student.rollNo);
                Navigator.pop(context); // Close the dialog.
                // Show a confirmation message.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${student.name}'s record deleted")),
                );
              },
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds a student card widget using StudentTile.
  Widget _buildStudentCard(Student student) {
    return StudentTile(
      student: student,
      // Pass the delete and update functions.
      onDelete: () => _showDeleteDialog(student),
      onUpdate: () => _showUpdateDialog(student),
    );
  }

  /// Shows a dialog to update student details.
  /// When the user confirms, it updates the record via the controller.
  void _showUpdateDialog(Student student) {
    // Create controllers for each field pre-filled with current student data.
    final TextEditingController nameController =
        TextEditingController(text: student.name);
    final TextEditingController classController =
        TextEditingController(text: student.className);
    final TextEditingController fatherNameController =
        TextEditingController(text: student.fatherName);
    final TextEditingController motherNameController =
        TextEditingController(text: student.motherName);
    final TextEditingController fatherPhoneController =
        TextEditingController(text: student.fatherPhone);
    final TextEditingController cnicController =
        TextEditingController(text: student.cnic);
    final TextEditingController addressController =
        TextEditingController(text: student.address);
    final TextEditingController dateOfBirthController =
        TextEditingController(text: student.dateOfBirth ?? '');
    final TextEditingController genderController =
        TextEditingController(text: student.gender);

    // Variable to store a new image URL if updated.
    String? newImageUrl;

    // Show an AlertDialog for updating student details.
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // Dialog title.
          title: const Text("Update Student Details"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Each TextField below is for a different student property.
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: TextEditingController(text: student.rollNo),
                  decoration: const InputDecoration(labelText: "Roll No"),
                  readOnly: true,
                ),
                TextField(
                  controller: classController,
                  decoration: const InputDecoration(labelText: "Class"),
                ),
                TextField(
                  controller: fatherNameController,
                  decoration: const InputDecoration(labelText: "Father Name"),
                ),
                TextField(
                  controller: motherNameController,
                  decoration: const InputDecoration(labelText: "Mother Name"),
                ),
                TextField(
                  controller: fatherPhoneController,
                  decoration: const InputDecoration(labelText: "Father Phone"),
                ),
                TextField(
                  controller: cnicController,
                  decoration: const InputDecoration(labelText: "CNIC"),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                ),
                TextField(
                  controller: dateOfBirthController,
                  decoration: const InputDecoration(labelText: "Date of Birth"),
                ),
                TextField(
                  controller: genderController,
                  decoration: const InputDecoration(labelText: "Gender"),
                ),
                // If there is an existing profile image, display it.
                if (student.studentPic != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Image.network(student.studentPic!, width: 100, height: 100),
                        const SizedBox(height: 8),
                        const Text("Current Profile Image"),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            // Cancel button: closes the dialog.
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            // Update button: updates the student record.
            TextButton(
              onPressed: () async {
                try {
                  // Construct an updated Student object with new values.
                  Student updatedStudent = Student(
                    name: nameController.text.trim(),
                    rollNo: student.rollNo,
                    className: classController.text.trim(),
                    fatherName: fatherNameController.text.trim(),
                    motherName: motherNameController.text.trim(),
                    fatherPhone: fatherPhoneController.text.trim(),
                    cnic: cnicController.text.trim(),
                    studentPic: newImageUrl ?? student.studentPic,
                    address: addressController.text.trim(),
                    dateOfBirth: dateOfBirthController.text.trim(),
                    gender: genderController.text.trim(),
                    createdAt: student.createdAt,
                    isPresent: student.isPresent,
                  );

                  // Update the student record using the controller.
                  await ref
                      .read(studentControllerProvider)
                      .updateStudent(updatedStudent);

                  // Show a confirmation message.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${student.name}'s details updated")),
                  );
                  Navigator.pop(context); // Close the dialog.
                } catch (e) {
                  // Show error message if update fails.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to update student")),
                  );
                }
              },
              child: const Text("Update", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the student list using Riverpod.
    final studentListAsyncValue = ref.watch(studentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Bar: allows users to filter by student name.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    // Update the search query state when the text changes.
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search students by name...',
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // Class Dropdown: filter students by class.
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: studentListAsyncValue.when(
                  data: (students) {
                    // Extract unique class names from the student list.
                    final classNames = students
                        .map((student) => student.className)
                        .toSet()
                        .toList()
                      ..sort();
                    // Insert a default option for "All Classes".
                    classNames.insert(0, "All Classes");

                    return DropdownButton<String>(
                      value: _selectedClass,
                      hint: const Text('Select a class'),
                      isExpanded: true,
                      items: classNames.map((className) {
                        return DropdownMenuItem<String>(
                          // If "All Classes" is selected, we set value to null.
                          value: className == "All Classes" ? null : className,
                          child: Text(className),
                        );
                      }).toList(),
                      onChanged: (value) {
                        // Update the selected class.
                        setState(() {
                          _selectedClass = value;
                        });
                      },
                    );
                  },
                  loading: () => Center(child: LiquidCircularProgressIndicator()),
                  error: (error, stack) => Text('Error: $error'),
                ),
              ),
              // Student List: displays filtered student cards.
              Expanded(
                child: studentListAsyncValue.when(
                  data: (students) {
                    // Filter students by search query and selected class.
                    final filteredStudents = students.where((student) {
                      final matchesClass = _selectedClass == null || student.className == _selectedClass;
                      final matchesSearch = student.name.toLowerCase().contains(_searchQuery);
                      return matchesClass && matchesSearch;
                    }).toList();

                    // Sort the filtered students alphabetically.
                    filteredStudents.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                    // If no students match, show a message.
                    if (filteredStudents.isEmpty) {
                      return const Center(child: Text('No matching students found.'));
                    }

                    // Build a ListView of student cards.
                    return ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        return _buildStudentCard(student);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),
          // Add Student Floating Button: navigates to the Add Student page.
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(AddStudent.pageName),
                child: Container(
                  width: 70,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      FittedBox(
                        child: Text(
                          'Add Student',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
