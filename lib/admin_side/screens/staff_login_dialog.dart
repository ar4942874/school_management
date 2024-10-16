import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_management/models/app_user.dart';
import 'package:school_management/models/staff.dart';
import 'package:school_management/admin_side/providers/firebase_auth_notifier.dart';
import 'package:school_management/staff_side/screens/staff_dashboard.dart'; // Ensure this import is correct

class StaffLoginDialog extends ConsumerWidget {
  const StaffLoginDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idController = TextEditingController();
    final passwordController = TextEditingController();

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
          onPressed: () async {
            final staffId = idController.text;
            final password = passwordController.text;

            final authNotifier =
                ref.read(firebaseAuthNotifierProvider.notifier);
            AppUser? staff =
                await authNotifier.staffSignIn(id: staffId, password: password);

            if (staff != null) {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pushReplacementNamed(
                  StaffDashboard.pageName); // Navigate to Staff Dashboard
            } else {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Login failed')));
            }
          },
          child: const Text('Login'),
        ),
      ],
    );
  }
}
