import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_management/admin_side/features/auth/controller/firebase_auth_notifier.dart';
import 'package:school_management/admin_side/features/auth/model/app_user.dart';

final authControllerProvider = Provider((ref) {
  final authNotifier = ref.read(firebaseAuthNotifierProvider.notifier);
  return AuthController(authNotifier);
});

class AuthController {
  final FirebaseAuthNotifier _authNotifier;

  AuthController(this._authNotifier);

  // Method for admin login
  Future<AppUser?> loginAsAdmin() async {
    return await _authNotifier.signInWithGoogle();
  }
  Future<AppUser?> loginAsStaff({required String id, required String password}) async {
    return await _authNotifier.staffSignIn(id: id, password: password);
  }

}
