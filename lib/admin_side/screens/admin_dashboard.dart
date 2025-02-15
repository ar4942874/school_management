import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:school_management/admin_side/features/auth/controller/firebase_auth_notifier.dart';
import 'package:school_management/admin_side/features/student_management/view/student_page.dart';
import 'package:school_management/admin_side/screens/staff_screen.dart';
import '../features/staff_attandenace.dart/view/staff_attendance_list.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});
  static const String pageName = '/Admin-Dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  actionsAlignment: MainAxisAlignment.center,
                  title: const Text(
                    'Do you want to sign out?',
                    style: TextStyle(fontSize: 18),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(firebaseAuthNotifierProvider.notifier)
                            .signOut();
                        Navigator.pop(context);
                      },
                      child: const Text('Yes'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('No'),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(FontAwesomeIcons.person),
        ),
        title: const Text(
          'Al Raza Public Middle School',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent.withOpacity(0.8),
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(), // Gradient background for visual appeal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader("Welcome Admin!"), // Dashboard title
                const SizedBox(height: 20),
                Expanded(
                  child: _buildCardsGrid(context), // Grid of cards
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF00C6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildCardsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 3 / 4,
      physics: const BouncingScrollPhysics(),
      children: [
        _buildAnimatedCard(
          context,
          title: "Students",
          icon: Icons.school,
          gradientColors: [Colors.blueAccent, Colors.lightBlueAccent],
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const StudentPage(),
            ));
          },
        ),
        _buildAnimatedCard(
          context,
          title: "Staff",
          icon: Icons.people,
          gradientColors: [Colors.greenAccent, Colors.teal],
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const StaffScreen(),
          )),
        ),
        _buildAnimatedCard(
          context,
          title: "Staff Attendance",
          icon: Icons.access_time,
          gradientColors: [Colors.orangeAccent, Colors.deepOrange],
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const StaffAttendanceList(),
          )),
        ),
        _buildAnimatedCard(
          context,
          title: "Leave Requests",
          icon: Icons.note_alt,
          gradientColors: [Colors.redAccent, Colors.pinkAccent],
          onTap: () => _navigateToDetail(context, "Leave Requests"),
        ),
      ],
    );
  }

  Widget _buildAnimatedCard(
    BuildContext context, {
    required String title, 
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[1].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(title: title),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;

  const DetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blueAccent.withOpacity(0.8),
      ),
      body: Center(
        child: Text(
          "Details for $title",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
