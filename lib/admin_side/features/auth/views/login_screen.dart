import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_management/admin_side/features/auth/controller/auth_controller.dart';
import 'package:school_management/admin_side/features/auth/model/app_user.dart';
import 'package:school_management/admin_side/screens/staff_login_dialog.dart';
import 'package:school_management/widgets/custom_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight - kToolbarHeight;
          return Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: maxWidth,
                  height: maxHeight * 0.5,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/school image.jpg',
                      ),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 0),
                        spreadRadius: 2,
                        color: Colors.black,
                        blurRadius: 5,
                      )
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 30.0, left: 15),
                  child: Text(
                    'Simplify your life and boost your productivity 🚀',
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 28.0, bottom: 28.0),
                  child: CustomButton(
                    icon: Container(
                      width: 40,
                      height: 540,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/google.png'))),
                    ),
                    height: maxHeight * 0.1,
                    width: maxWidth * 0.9,
                    color: Colors.amber,
                    callback: () async {
                      final authController =
                          ref.read(authControllerProvider);
                      AppUser? user = await authController.loginAsAdmin();
                    },
                    borderRadius: 10,
                    text: 'Login as Admin',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                  ),
                  child: CustomButton(
                    icon: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                    height: maxHeight * 0.1,
                    width: maxWidth * 0.9,
                    color: const Color.fromARGB(161, 44, 108, 245),
                    callback: () {
                      // Show the staff login dialog
                      showDialog(
                        context: context,
                        builder: (context) => const StaffLoginDialog(),
                      );
                    },
                    borderRadius: 10,
                    text: 'Login as Staff',
                    fontWeight: FontWeight.bold,
                    textColor: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    'By logging in, you consent to our terms of service and privacy policy.',
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
