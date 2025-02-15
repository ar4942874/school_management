
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_management/admin_side/features/student_management/model/student.dart';


/// Controller for handling all student-related Firestore operations.
class StudentController {
  // Firestore instance to perform database operations.
  final FirebaseFirestore firestore;

  // Constructor: inject Firestore.
  StudentController({required this.firestore});

  /// Returns a stream of Student objects from the 'students' collection.
  Stream<List<Student>> watchStudents() {
    return firestore.collection('students').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Convert Firestore document data to a Student model.
        return Student.fromMap(doc.data());
      }).toList();
    });
  }

  /// Deletes a student record based on the roll number.
  Future<void> deleteStudent(String rollNo) async {
    final query = await firestore
        .collection('students')
        .where('rollNo', isEqualTo: rollNo)
        .get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }

  /// Updates an existing student record using the updated Student object.
  Future<void> updateStudent(Student updatedStudent) async {
    final query = await firestore
        .collection('students')
        .where('rollNo', isEqualTo: updatedStudent.rollNo)
        .get();
    for (var doc in query.docs) {
      await doc.reference.update(updatedStudent.toMap());
    }
  }

  /// Adds a student record to Firestore in a flat structure.
  /// Generates a unique document ID using the class name and roll number.
  Future<bool> addStudent(Map<String, dynamic> studentData) async {
    try {
      // Create a unique ID: "class<className>_rollNo<rollNo>"
      String uniqueId =
          "class${studentData['className']}_rollNo${studentData['rollNo']}";
      // Store the student data in the 'students' collection using merge options.
      await firestore
          .collection('students')
          .doc(uniqueId)
          .set(studentData, SetOptions(merge: true));
      return true; // Successfully stored student data.
    } catch (e) {
      print("Error storing student data: $e");
      return false; // An error occurred.
    }
  }
}

/// Riverpod provider that exposes the StudentController.
final studentControllerProvider = Provider<StudentController>((ref) {
  return StudentController(firestore: FirebaseFirestore.instance);
});

/// Riverpod stream provider for the list of students.
final studentListProvider = StreamProvider<List<Student>>((ref) {
  final controller = ref.watch(studentControllerProvider);
  return controller.watchStudents();
});
