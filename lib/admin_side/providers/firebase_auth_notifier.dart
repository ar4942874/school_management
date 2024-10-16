import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:school_management/models/app_user.dart';
import 'package:school_management/models/staff.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'firebase_providers.dart';

// // Define StateNotifier to handle Firebase functions
// class FirebaseAuthNotifier extends StateNotifier<User?> {
//   final FirebaseAuth _auth;
//   final GoogleSignIn _googleSignIn;
//   final FirebaseFirestore _firestore;

//   FirebaseAuthNotifier(this._auth, this._googleSignIn, this._firestore)
//       : super(_auth.currentUser); // Initialize state with the current user

//   // Method to sign in with Google, returns User?
//   Future<User?> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         // If the user cancels the sign-in process
//         return null;
//       }

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       UserCredential userCredential =
//           await _auth.signInWithCredential(credential);
//       User? user = userCredential.user;

//       if (user != null) {
//           final prefs=await SharedPreferences.getInstance();
//        await prefs.setString('userRole', 'admin');
//         state = user; // Update the state with the signed-in user
//         await _firestore.collection('admins').doc(user.uid).set({
//           'uid': user.uid,
//           'name': user.displayName,
//           'email': user.email,
//           'photoURL': user.photoURL,
//           'lastSignIn': DateTime.now(),
//           'role': 'admin',
//         }, SetOptions(merge: true));
//       }

//       return user; // Return the signed-in user
//     } catch (e) {
//       print('Error signing in with Google: $e');
//       return null; // Return null if an error occurs
//     }
//   }

//   Future<Staff?> staffSignIn(
//       {required String id, required String password}) async {
//     try {
//       var querySnapshot = await _firestore
//           .collection('staff')
//           .where('id', isEqualTo: id)
//           .where('password', isEqualTo: password)
//           .get();
//       if (querySnapshot.docs.isNotEmpty) {
//         // Return the first matching document's staff details
//         final staffDoc = querySnapshot.docs.first;

//         // Update the role in Firestore if it's missing
//         if (staffDoc.exists) {
//           await _firestore.collection('staff').doc(staffDoc.id).set({
//             'role': 'staff', // Ensure the role is set in the staff document
//           }, SetOptions(merge: true));
//         }
//         final prefs=await SharedPreferences.getInstance();
//        await prefs.setString('userRole', 'staff');

// // Create a dummy User object or use an appropriate method to handle staff login
//       final user = AppUser(
//         uid: staffDoc.id,
//         email: staffDoc.data()['email'],
//         displayName: staffDoc.data()['name'],
//         photoURL: staffDoc.data()['photoURL'],
//         role: 'staff'

//       );

//       // Update the state with the User object
//         return Staff.fromDocument(staffDoc);
//       } else {
//         // Login failed
//         return null;
//       }
//     } catch (e) {
//       return null;
//     }
//   }

//   // Method to store staff data in Firestore
//   Future<void> storeStaffData(Map<String, dynamic> staffData) async {
//     String id = const Uuid().v1();
//     try {
//       User? user = state; // Using the state to get the current user
//       if (user != null) {
//         staffData['adminId'] = user.uid; // Add adminId to staffData
//         await _firestore
//             .collection('staff')
//             .doc(id)
//             .set(staffData, SetOptions(merge: true));
//       } else {
//         print("No user is currently signed in.");
//       }
//     } catch (e) {
//       print("Error storing staff data: $e");
//     }
//   }

//   // Method to store student data in Firestore
//   Future<bool> storeStudentData(Map<String, dynamic> studentData) async {
//     String id = const Uuid().v1();
//     try {
//       User? user = state; // Using the state to get the current user
//       if (user != null) {
//         await _firestore
//             .collection('students')
//             .doc(id)
//             .set(studentData, SetOptions(merge: true));
//         return true;
//       } else {
//         print("No user is currently signed in.");
//         return false;
//       }
//     } catch (e) {
//       print("Error storing student data: $e");
//       return false;
//     }
//   }

//   Future<String?> getUserRole() async {
//     // Access SharedPreferences to retrieve the stored role
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('userRole'); // Return 'admin' or 'staff'
//   }

//    // Method to sign out, doesn't need to return anything
//   Future<void> signOut() async {
//     final prefs = await SharedPreferences.getInstance();
//   await prefs.clear();
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//     state = null; // Reset the state to null after sign out
//   }
// }

// // FirebaseAuthNotifier provider
// final firebaseAuthNotifierProvider =
//     StateNotifierProvider<FirebaseAuthNotifier, User?>((ref) {
//   final auth = ref.read(firebaseAuthProvider);
//   final googleSignIn = ref.read(googleSignInProvider);
//   final firestore = ref.read(firestoreProvider);
//   return FirebaseAuthNotifier(auth, googleSignIn, firestore);
// });
class FirebaseAuthNotifier extends StateNotifier<AppUser?> {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  FirebaseAuthNotifier(this._auth, this._googleSignIn, this._firestore)
      : super(null); // Initially, no user is logged in

  // Method to sign in with Google, returns AppUser
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
        // Set role to 'admin' and save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', 'admin');

        // Save admin data to Firestore
        await _firestore.collection('admins').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
          'lastSignIn': DateTime.now(),
          'role': 'admin',
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

  // Method to sign in as staff, returns AppUser
  Future<AppUser?> staffSignIn(
      {required String id, required String password}) async {
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

        // Store role in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', 'staff');
        await prefs.setString('userId', staffDoc.id);
        await prefs.setString('userPassword', password);

        // Create AppUser for staff and update state
        state = AppUser.fromDocument(
          staffDoc,
        );
        return state;
      } else {
        return null; // Staff not found
      }
    } catch (e) {
      return null;
    }
  }

  // Stream for staff sign-in
 
  // Sign out method
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _googleSignIn.signOut();
    await _auth.signOut();
    state = null; // Reset the state to null
  }

  // Method to get user role from SharedPreferences
  Stream<String?> getUserRole() async* {
    final prefs = await SharedPreferences.getInstance();
    yield prefs.getString('userRole');
  }

  Future<bool> storeStudentData(Map<String, dynamic> studentData) async {
    String id = const Uuid().v1(); // Generate a unique ID for the student
    try {
      AppUser? appUser = state; // Use AppUser instead of User
      if (appUser != null) {
        // Add adminId or staffId (whoever is logged in) to studentData
        studentData['addedBy'] = appUser.uid;

        // Store the student data in Firestore
        await _firestore
            .collection('students')
            .doc(id)
            .set(studentData, SetOptions(merge: true));

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
    StateNotifierProvider<FirebaseAuthNotifier, AppUser?>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  final googleSignIn = ref.read(googleSignInProvider);
  final firestore = ref.read(firestoreProvider);
  return FirebaseAuthNotifier(auth, googleSignIn, firestore);
});
