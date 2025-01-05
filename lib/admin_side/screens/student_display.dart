import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:school_management/admin_side/screens/add_student.dart';
import 'package:school_management/admin_side/screens/student_tile.dart';
import 'package:school_management/models/student.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});
  static const String pageName = '/students-page';

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  void _showDeleteDialog(Student student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Student"),
          content: Text(
            "Are you sure you want to delete ${student.name}'s record?",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                // Call the delete function
                await _deleteStudentRecord(student);
                Navigator.pop(context); // Close the dialog
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

  Future<void> _deleteStudentRecord(Student student) async {
    try {
      // Assuming documentId is stored in student.rollNo or another unique field
      final QuerySnapshot query = await firestore
          .collection('students')
          .where('rollNo', isEqualTo: student.rollNo) // Adjust field as needed
          .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }

      print("Deleted ${student.name}'s record successfully");
    } catch (e) {
      print("Error deleting record: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete student record")),
      );
    }
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool isExpanded = false;
  String? _selectedClass;

  @override
  Widget build(BuildContext context) {
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
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
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
              // Class Dropdown
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('students')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: LiquidCircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('No classes available.');
                    }

                    // Extract unique class names
                    final classNames = snapshot.data!.docs
                        .map((doc) => (doc['className'] as String))
                        .toSet()
                        .toList()
                      ..sort();
                    classNames.insert(0, "All Classes");

                    return DropdownButton<String>(
                      value: _selectedClass,
                      hint: const Text('Select a class'),
                      isExpanded: true,
                      items: classNames.map((className) {
                        return DropdownMenuItem<String>(
                          value: className == "All Classes" ? null : className,
                          child: Text(className),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClass = value;
                        });
                      },
                    );
                  },
                ),
              ),
              // Student List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('students')
                      .snapshots(),
                  builder: (context, snapshot) {
                    // if (snapshot.connectionState == ConnectionState.waiting) {
                    //   return const Center(child: CircularProgressIndicator());
                    // }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No students found.'));
                    }

                    // Filter students based on the selected class and search query
                    final students = snapshot.data!.docs
                        .map((doc) =>
                            Student.fromMap(doc.data() as Map<String, dynamic>))
                        .where((student) =>
                            (_selectedClass == null ||
                                student.className == _selectedClass) &&
                            student.name.toLowerCase().contains(_searchQuery))
                        .toList();

                    students.sort((a, b) =>
                        a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                    if (students.isEmpty) {
                      return const Center(
                          child: Text('No matching students found.'));
                    }

                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return _buildStudentCard(student);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Add Student Button
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

  Widget _buildStudentCard(Student student) {
    return StudentTile(
        student: student,
        onDelete: () => _showDeleteDialog(student),
        onUpdate: () => _showUpdateDialog(student, context));
  }
}

void _showUpdateDialog(Student student, BuildContext context) async {
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

  String? newImageUrl;

  // final ImagePicker _picker = ImagePicker();

  // // Function to pick an image
  // Future<void> _pickImage() async {
  //   final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     final file = File(pickedFile.path);

  //     // Upload the image to Firebase Storage
  //     try {
  //       final fileName = path.basename(file.path);
  //       final storageRef = FirebaseStorage.instance.ref().child('student_images/$fileName');

  //       await storageRef.putFile(file);
  //       newImageUrl = await storageRef.getDownloadURL(); // Get the URL of the uploaded image
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Image uploaded successfully")),
  //       );
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Failed to upload image")),
  //       );
  //     }
  //   }
  // }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Update Student Details"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name Field
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              // Read-only Roll No Field
              TextField(
                controller: TextEditingController(text: student.rollNo),
                decoration: const InputDecoration(labelText: "Roll No"),
                readOnly: true,
              ),
              // Class Field
              TextField(
                controller: classController,
                decoration: const InputDecoration(labelText: "Class"),
              ),
              // Father Name Field
              TextField(
                controller: fatherNameController,
                decoration: const InputDecoration(labelText: "Father Name"),
              ),
              // Mother Name Field
              TextField(
                controller: motherNameController,
                decoration: const InputDecoration(labelText: "Mother Name"),
              ),
              // Father Phone Field
              TextField(
                controller: fatherPhoneController,
                decoration: const InputDecoration(labelText: "Father Phone"),
              ),
              // CNIC Field
              TextField(
                controller: cnicController,
                decoration: const InputDecoration(labelText: "CNIC"),
              ),
              // Address Field
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address"),
              ),
              // Date of Birth Field
              TextField(
                controller: dateOfBirthController,
                decoration: const InputDecoration(labelText: "Date of Birth"),
              ),
              // Gender Field
              TextField(
                controller: genderController,
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              // Current Image (Optional)
              if (student.studentPic != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Image.network(student.studentPic!,
                          width: 100, height: 100),
                      const SizedBox(height: 8),
                      const Text("Current Profile Image"),
                    ],
                  ),
                ),
              // Button to change image
              // ElevatedButton(
              //   onPressed: _pickImage,
              //   child: const Text("Change Image"),
              // ),
            ],
          ),
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text("Cancel"),
          ),
          // Update Button
          TextButton(
            onPressed: () async {
              try {
                // Construct the updated student object
                Student updatedStudent = Student(
                  name: nameController.text.trim(),
                  rollNo: student.rollNo, // Roll No remains unchanged
                  className: classController.text.trim(),
                  fatherName: fatherNameController.text.trim(),
                  motherName: motherNameController.text.trim(),
                  fatherPhone: fatherPhoneController.text.trim(),
                  cnic: cnicController.text.trim(),
                  studentPic:
                      newImageUrl ?? student.studentPic, // Update image URL
                  address: addressController.text.trim(),
                  dateOfBirth: dateOfBirthController.text.trim(),
                  gender: genderController.text.trim(),
                  createdAt: student.createdAt, // Keep original createdAt
                  isPresent:
                      student.isPresent, // Keep original attendance status
                );

                // Update Firestore using the toMap() method
                final QuerySnapshot query = await FirebaseFirestore.instance
                    .collection('students')
                    .where('rollNo', isEqualTo: student.rollNo)
                    .get();

                for (var doc in query.docs) {
                  await doc.reference.update(updatedStudent.toMap());
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${student.name}'s details updated"),
                  ),
                );

                Navigator.pop(context); // Close dialog
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to update student")),
                );
              }
            },
            child: const Text(
              "Update",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}
