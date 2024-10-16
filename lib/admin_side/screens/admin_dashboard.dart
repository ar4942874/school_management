import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:school_management/admin_side/components/components.dart';
import 'package:school_management/admin_side/providers/firebase_auth_notifier.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});
  static const String pageName = '/Admin-Dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                ref.read(firebaseAuthNotifierProvider.notifier).signOut();
              }, icon: const Icon(FontAwesomeIcons.person)),
          title: const Text(
            'Al Raza Public Middle School',
            style: TextStyle(fontSize: 15),
          ),
          backgroundColor: Colors.grey.withOpacity(0.2),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: Icon(Icons.settings),
            )
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          double maxHeight = constraints.maxHeight;
          double maxWidth = constraints.maxWidth * 0.92;
          return Stack(children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: OverviewSection(
                          maxWidth: maxWidth, maxHeight: maxHeight),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: AttendanceSection(
                        maxHeight: maxHeight * 0.5,
                        maxWidth: maxWidth,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Align(
                alignment: Alignment(0.8, 0.9),
                child: CustomFloatingActionButton())
          ]);
        }));
  }
}
