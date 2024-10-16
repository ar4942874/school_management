import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});
  static const pageName = '/staff-dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Name'),
        leading: Consumer(
          builder: (context, ref, child) {
            return const Text('A');
          },
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person),
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                width: 150,
                height: 150,
                color: Colors.amberAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
