import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:school_management/admin_side/features/auth/model/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'firebase_providers.dart';

final isLoadingProvider = StateProvider<bool>((ref) => true);

class FirebaseAuthNotifier extends StateNotifier<AppUser?> {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  bool isLoading = true;
  final Ref ref;

  FirebaseAuthNotifier(
      this._auth, this._googleSignIn, this._firestore, this.ref)
      : super(null) {
    _initUserRole();
  }

  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Save user role and data in SharedPreferences
        await _storeUserRole('admin', user.uid, userCredential.user!.email!);

        // Save admin data to Firestore
        await _firestore.collection('admins').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
          'lastSignIn': DateTime.now(),
        }, SetOptions(merge: true));

        // Update state with the signed-in user
        state = AppUser(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName!,
          photoURL: user.photoURL,
          role: 'admin',
        );
        return state;
      }
      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Method to sign in as staff, returns AppUser
  Future<AppUser?> staffSignIn({
    required String id,
    required String password,
  }) async {
    try {
      var querySnapshot = await _firestore
          .collection('staff')
          .where('id', isEqualTo: id)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final staffDoc = querySnapshot.docs.first;
        if (staffDoc.exists) {
          await _firestore.collection('staff').doc(staffDoc.id).set({
            'role': 'staff',
          }, SetOptions(merge: true));
        }

        String className= staffDoc['class'];
        final local = await SharedPreferences.getInstance();
        local.setString("staffID", staffDoc.id);
        // Save user role and data in SharedPreferences
        await _storeUserRole('staff', staffDoc.id, id, className: className);
       
        // Create AppUser for staff and update state
        state = AppUser.fromDocument(staffDoc);
        return state;
      } else {
        return null; // Staff not found
      }
    } catch (e) {
      print('Error signing in staff: $e');
      return null;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _clearUserRole();
      state = null; // Reset the state to null
    } catch (e) {
      print('Error during sign-out: $e');
    }
  }

  // Method to initialize the user role from SharedPreferences
  Future<void> _initUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    String? currentRole = prefs.getString('userRole');
    String? currentUserId = prefs.getString('userId');
    String? userEmail = prefs.getString('userEmail');

    if (currentRole != null && currentUserId != null) {
      state = AppUser(
        uid: currentUserId,
        email: userEmail ?? '',
        displayName: '', // Add displayName if needed
        role: currentRole,
      );
    }
    ref.read(isLoadingProvider.notifier).state = false;
  }

  // Store user role and relevant data in SharedPreferences
  Future<void> _storeUserRole(
      String role, String userId, String userEmail, {String className=''}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);
    await prefs.setString('userId', userId);
    await prefs.setString('userEmail', userEmail);
    await prefs.setString('className', className);
    
  }

  // Clear user role on sign-out
  Future<void> _clearUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userRole');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('className');
    await prefs.reload();
  }

  // Store staff data
  Future<void> storeStaffData(Map<String, dynamic> staffData) async {
    String id = const Uuid().v1(); // Generate a unique ID for the staff
    try {
      AppUser? appUser = state; // Use AppUser instead of User
      if (appUser != null) {
        // Store the staff data in Firestore without the addedBy field
        await _firestore
            .collection('staff')
            .doc(id)
            .set(staffData, SetOptions(merge: true));
      } else {
        print("No user is currently signed in.");
      }
    } catch (e) {
      print("Error storing staff data: $e");
    }
  }

  // Store student data in a flat structure
Future<bool> storeStudentData(Map<String, dynamic> studentData) async {
  try {
    AppUser? appUser = state; // Use AppUser instead of User
    if (appUser != null) {
      // Store the student data in the 'students' collection with a unique ID
      String uniqueId = "class${studentData['className']}_rollNo${studentData['rollNo']}";

      await _firestore
          .collection('students') // Flat collection at the root level
          .doc(uniqueId) // Unique document ID combining class and roll number
          .set(studentData, SetOptions(merge: true)); // Merge if document exists

      return true; // Successfully stored the student data
    } else {
      print("No user is currently signed in.");
      return false; // No user signed in, cannot store data
    }
  } catch (e) {
    print("Error storing student data: $e");
    return false; // Error occurred during storing data
  }
}

}

final firebaseAuthNotifierProvider =
    StateNotifierProvider<FirebaseAuthNotifier,AppUser?>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  final googleSignIn = ref.read(googleSignInProvider);
  final firestore = ref.read(firestoreProvider);
  return FirebaseAuthNotifier(auth, googleSignIn, firestore, ref);
});
