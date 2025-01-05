import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_management/admin_side/features/auth/controller/auth_controller.dart';
import 'package:school_management/admin_side/features/auth/model/app_user.dart';

class StaffLoginDialog extends StatefulWidget {
  const StaffLoginDialog({super.key});

  @override
  _StaffLoginDialogState createState() => _StaffLoginDialogState();
}

class _StaffLoginDialogState extends State<StaffLoginDialog> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) { // Use Consumer to get ref
        return AlertDialog(
          title: const Text('Staff Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'Staff ID'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              if (isLoading) // Show loading indicator if login is in progress
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isLoading ? null : () => _login(context, ref), // Pass ref to _login
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _login(BuildContext context, WidgetRef ref) async {
    final staffId = idController.text;
    final password = passwordController.text;

    if (staffId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() {
      isLoading = true; // Set loading to true
    });

    final authController = ref.read(authControllerProvider); // Use ref.read to access providers
    AppUser? staff =
        await authController.loginAsStaff(id: staffId, password: password);
        Navigator.of(context).pop();

    setState(() {
      isLoading = false; // Set loading to false after login
    });
  }
}
