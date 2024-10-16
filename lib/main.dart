import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_management/admin_side/screens/admin_dashboard.dart';
import 'package:school_management/admin_side/providers/firebase_auth_notifier.dart';
import 'package:school_management/routes.dart';
import 'package:school_management/screens/login_screen.dart';
import 'package:school_management/staff_side/screens/staff_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized

  runApp(
    const ProviderScope(child: MyApp()), // Wrap with ProviderScope
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(), 
      onGenerateRoute: onGenerateRoute,
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(firebaseAuthNotifierProvider.notifier).getUserRole();
    return StreamBuilder<String?>(
      stream: authNotifier,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(backgroundColor: Colors.amberAccent)),
          );
        }


        if (authSnapshot.connectionState== ConnectionState.done) {
          final role = authSnapshot.data;
                if (role == 'admin') {
                  return const AdminDashboard();
                } else if (role == 'staff') {
                  return const StaffDashboard();
                }
        }
        return const LoginScreen();
      },
    );
  }
}



