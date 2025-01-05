import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../model/staff_attendance_model.dart';

class StaffAttendanceController {
  final CollectionReference _attendanceCollection =
      FirebaseFirestore.instance.collection('staffAttendance');

  // Method to mark attendance
  Future<void> markAttendance({
    required String staffId,
    required double targetLatitude,
    required double targetLongitude,
    double radius = 100.0, // Radius in meters
  }) async {
    // Check if location services are enabled
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are disabled.');
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(accuracy: LocationAccuracy.high),
    );

    // Calculate distance
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      targetLatitude,
      targetLongitude,
    );

    // Get current date and time
    DateTime now = DateTime.now();
    String formattedDate = "${now.year}-${now.month}-${now.day}";
    DateTime deadline =
        DateTime(now.year, now.month, now.day, 9, 0, 0); // 9:00 AM deadline

    // Check if time is valid
    if (now.isAfter(deadline)) {
      throw Exception('Attendance cannot be marked after 9:00 AM.');
    }

    // Check proximity
    if (distance > radius) {
      throw Exception('You are not within the required location range.');
    }

    // Create attendance object
    StaffAttendance attendance = StaffAttendance(
      staffId: staffId,
      attendanceMarked: true,
      date: formattedDate,
      time: "${now.hour}:${now.minute}:${now.second}",
      timestamp: now,
      location: {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
    );

    // Save to Firestore
    await _attendanceCollection
        .doc("$staffId-$formattedDate") // Unique ID
        .set(attendance.toMap(), SetOptions(merge: true));
  }
}
