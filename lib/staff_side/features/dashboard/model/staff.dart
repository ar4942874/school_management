import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaffData {
  final String adminId;
  final String staffName;
  final String joinDate;
  final String gender;
  final String textNumber;
  final String whatsapp;
  final String address;
  final String id;
  final String password;
  final String staffClass;
  final String salary;
  final String qualification;

  StaffData({
    required this.adminId,
    required this.staffName,
    required this.joinDate,
    required this.gender,
    required this.textNumber,
    required this.whatsapp,
    required this.address,
    required this.id,
    required this.password,
    required this.staffClass,
    required this.salary,
    required this.qualification,
  });

  // Convert a StaffData object to a Map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'staffName': staffName,
      'joinDate': joinDate,
      'gender': gender,
      'textNumber': textNumber,
      'whatsapp': whatsapp,
      'address': address,
      'id': id,
      'password': password,
      'class': staffClass,
      'salary': salary,
      'qualification': qualification,
    };
  }

  // Convert a Firestore document to a StaffData object
  factory StaffData.fromMap(Map<String, dynamic> map) {
    return StaffData(
      adminId: map['adminId'],
      staffName: map['staffName'],
      joinDate: map['joinDate'],
      gender: map['gender'],
      textNumber: map['textNumber'],
      whatsapp: map['whatsapp'],
      address: map['address'],
      id: map['id'],
      password: map['password'],
      staffClass: map['class'],
      salary: map['salary'],
      qualification: map['qualification'],
    );
  }
}


class StaffRepository {
  final FirebaseFirestore firestore;

  StaffRepository({required this.firestore});

  Future<StaffData> fetchStaffData() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('userEmail');

    if (id == null) throw Exception('User email not found in preferences');

    final querySnapshot = await firestore
        .collection('staff')
        .where('id', isEqualTo: id)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return StaffData.fromMap(doc.data());
    } else {
      throw Exception('Staff data not found for ID: $id');
    }
  }
}