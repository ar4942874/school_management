import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_management/admin_side/screens/admin_dashboard.dart';
import 'package:school_management/admin_side/features/auth/controller/firebase_auth_notifier.dart';
import 'package:school_management/admin_side/screens/circular_progress_indicator.dart';
import 'package:school_management/routes.dart';
import 'package:school_management/admin_side/features/auth/views/login_screen.dart';
import 'package:school_management/staff_side/features/dashboard/view/staff_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    await Supabase.initialize(
      url: 'https://zeflkhhpdkaxonesagoy.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InplZmxraGhwZGtheG9uZXNhZ295Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA5NjA0MzUsImV4cCI6MjA0NjUzNjQzNX0.sCCWuoDi5cSntU4j59Oj5jEnfzpYJsnKlUatTaNn9b4',
    );
  } catch (e) {
    debugPrint("Error initializing Supabase: $e");
  }
  runApp(
    const ProviderScope(child: MyApp()),
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
    // Watch the isLoading state and appUser
    final isLoading = ref.watch(isLoadingProvider);
    final appUser = ref.watch(firebaseAuthNotifierProvider);

    if (isLoading) {
      return const CustomLiquidProgressIndicator();
    }
    // If `appUser` is null after loading, the user is logged out
    if (appUser == null) {
      return const LoginScreen();
    }

    // Check role and navigate accordingly
    switch (appUser.role) {
      case 'admin':
        return const AdminDashboard();
      case 'staff':
        return const StaffDashboard();
      default:
        return const LoginScreen();
    }
  }
}
