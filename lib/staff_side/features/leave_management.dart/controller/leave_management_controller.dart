import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_management/staff_side/features/leave_management.dart/model/leave_request.dart';

class LeaveManagementController extends StateNotifier<List<LeaveRequest>> {
  LeaveManagementController() : super([]) {
    fetchLeaveRequests();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Submit a leave request
  Future<void> submitLeaveRequest(LeaveRequest request) async {
    try {
      await firestore.collection('leave_requests').add(request.toFirestore());
    } catch (e) {
      throw Exception("Error submitting request: $e");
    }
  }

  // Fetch leave requests and update the state
  void fetchLeaveRequests() {
    firestore
        .collection('leave_requests')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final leaveRequests = snapshot.docs.map((doc) {
        return LeaveRequest.fromFirestore(doc.data(), doc.id);
      }).toList();
      state = leaveRequests; // Update state with new data
    });
  }
}

// Create a provider for the LeaveManagementController
final leaveManagementProvider =
    StateNotifierProvider<LeaveManagementController, List<LeaveRequest>>(
  (ref) => LeaveManagementController(),
);
