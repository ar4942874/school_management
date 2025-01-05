import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_management/staff_side/features/dashboard/model/staff.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository(firestore: FirebaseFirestore.instance);
});

final staffDataProvider = FutureProvider<StaffData>((ref) async {
  final repository = ref.read(staffRepositoryProvider);
  return repository.fetchStaffData();
});
