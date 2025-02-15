import 'dart:convert';

class Student {
  String name;
  String fatherName;
  String rollNo;
  String? dateOfBirth;
  String fatherPhone;
  String className;
  String address;
  String createdAt;
  String gender;
  String cnic;
  String motherName;
  String? studentPic;
  bool isPresent; 

  Student({
    required this.name,
    required this.fatherName,
    required this.rollNo,
    this.dateOfBirth,
    required this.fatherPhone,
    required this.className,
    required this.address,
    required this.createdAt,
    required this.gender,
    required this.cnic,
    required this.motherName,
    this.studentPic,
    this.isPresent = false, 
  });

  Student copyWith({
    String? name,
    String? fatherName,
    String? rollNo,
    String? dateOfBirth,
    String? fatherPhone,
    String? className,
    String? address,
    String? createdAt,
    String? gender,
    String? cnic,
    String? motherName,
    String? studentPic,
    bool? isPresent,
  }) {
    return Student(
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      rollNo: rollNo ?? this.rollNo,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      fatherPhone: fatherPhone ?? this.fatherPhone,
      className: className ?? this.className,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      gender: gender ?? this.gender,
      cnic: cnic ?? this.cnic,
      motherName: motherName ?? this.motherName,
      studentPic: studentPic ?? this.studentPic,
      isPresent: isPresent ?? this.isPresent, // Include attendance status in copy
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'fatherName': fatherName,
      'rollNo': rollNo,
      'dateOfBirth': dateOfBirth ?? 'No Time',
      'fatherPhone': fatherPhone,
      'className': className,
      'address': address,
      'createdAt': createdAt,
      'gender': gender,
      'cnic': cnic,
      'motherName': motherName,
      'studentPic': studentPic,
      'isPresent': isPresent, // Add to map
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      name: map['name'] as String,
      fatherName: map['fatherName'] as String,
      rollNo: map['rollNo'] as String,
      dateOfBirth: map['dateOfBirth'] as String?,
      fatherPhone: map['fatherPhone'] as String,
      className: map['className'] as String,
      address: map['address'] as String,
      createdAt: map['createdAt'] as String,
      gender: map['gender'] as String,
      cnic: map['cnic'] as String,
      motherName: map['motherName'] as String,
      studentPic: map['studentPic'] as String?,
      isPresent: map['isPresent'] as bool? ?? false, // Initialize from map or default to false
    );
  }

  String toJson() => json.encode(toMap());

  factory Student.fromJson(String source) =>
      Student.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Student(name: $name, fatherName: $fatherName, rollNo: $rollNo, dateOfBirth: $dateOfBirth, fatherPhone: $fatherPhone, className: $className, address: $address, createdAt: $createdAt, gender: $gender, cnic: $cnic, motherName: $motherName, studentPic: $studentPic, isPresent: $isPresent)';
  }

  @override
  bool operator ==(covariant Student other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.fatherName == fatherName &&
        other.rollNo == rollNo &&
        other.dateOfBirth == dateOfBirth &&
        other.fatherPhone == fatherPhone &&
        other.className == className &&
        other.address == address &&
        other.createdAt == createdAt &&
        other.gender == gender &&
        other.cnic == cnic &&
        other.motherName == motherName &&
        other.studentPic == studentPic &&
        other.isPresent == isPresent; // Include in equality check
  }

  @override
  int get hashCode {
    return name.hashCode ^
        fatherName.hashCode ^
        rollNo.hashCode ^
        dateOfBirth.hashCode ^
        fatherPhone.hashCode ^
        className.hashCode ^
        address.hashCode ^
        createdAt.hashCode ^
        gender.hashCode ^
        cnic.hashCode ^
        motherName.hashCode ^
        studentPic.hashCode ^
        isPresent.hashCode; // Include in hash calculation
  }
}
