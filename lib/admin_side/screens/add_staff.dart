import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_management/admin_side/components/components.dart';
import 'package:school_management/admin_side/screens/admin_dashboard.dart';
import 'package:school_management/admin_side/providers/add_staff_providers.dart';
import 'package:school_management/admin_side/providers/firebase_auth_notifier.dart'; // Import the providers

class AddStaff extends ConsumerWidget {
  const AddStaff({super.key});
  static const String pageName = '/Add-Staff';

  void _onNextStep(BuildContext context, WidgetRef ref) {
    final currentStep = ref.read(currentStepProvider);
    final formKeys = [
      ref.read(basicInfoFormKeyProvider),
      ref.read(contactInfoFormKeyProvider),
      ref.read(instituteInfoFormKeyProvider),
    ];

    if (formKeys[currentStep].currentState!.validate()) {
      if (currentStep == formKeys.length - 1) {
        _saveStaffData(context, ref);
      } else {
        ref.read(currentStepProvider.notifier).state++;
        ref.read(pageControllerProvider).nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    }
  }

  Future<void> _saveStaffData(BuildContext context, WidgetRef ref) async {
    try {
      final staffData = {
        'staffName': ref.read(staffNameControllerProvider).text,
        'joinDate': ref.read(joinDateControllerProvider).text,
        'gender': ref.read(genderControllerProvider).text,
        'textNumber': ref.read(textNumberControllerProvider).text,
        'whatsapp': ref.read(whatsAppControllerProvider).text,
        'address': ref.read(addressControllerProvider).text,
        'id': ref.read(idControllerProvider).text,
        'password': ref.read(passwordControllerProvider).text,
        'class': ref.read(classControllerProvider).text,
        'salary': ref.read(salaryControllerProvider).text,
        'qualification': ref.read(qualificationControllerProvider).text,
      }; 

      await ref.read(firebaseAuthNotifierProvider.notifier).storeStaffData(staffData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff data saved successfully!')),
      );
      Navigator.of(context).pushNamed(AdminDashboard.pageName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save staff data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(currentStepProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add Staff',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.black,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight - kToolbarHeight;
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                SizedBox(
                  width: maxWidth * 0.9,
                  height: maxHeight * 0.15,
                  child: GestureDetector(
                    onTap: () => ref.read(currentStepProvider.notifier).state = currentStep,
                    child: CustomSteppers(
                      backgroundColor: Colors.black.withOpacity(0.1),
                      currentStep: currentStep,
                    ),
                  ),
                ),
                SizedBox(height: maxHeight * 0.003),
                Container(
                  height: maxHeight * 0.75,
                  width: maxWidth * 0.9,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: ref.watch(pageControllerProvider),
                    onPageChanged: (index) {
                      ref.read(currentStepProvider.notifier).state = index;
                    },
                    children: [
                      Form(
                        key: ref.read(basicInfoFormKeyProvider),
                        child: BasicInfo(
                          maxWidth: maxWidth,
                          maxHeight: maxHeight,
                          joinDateController: ref.read(joinDateControllerProvider),
                          staffNameController: ref.read(staffNameControllerProvider),
                          genderController: ref.read(genderControllerProvider),
                        ),
                      ),
                      Form(
                        key: ref.read(contactInfoFormKeyProvider),
                        child: ContactInfo(
                          maxHeight: maxHeight,
                          maxWidth: maxWidth,
                          textNumberController: ref.read(textNumberControllerProvider),
                          whatsAppController: ref.read(whatsAppControllerProvider),
                          addressController: ref.read(addressControllerProvider),
                        ),
                      ),
                      Form(
                        key: ref.read(instituteInfoFormKeyProvider),
                        child: InstituteInfo(
                          maxHeight: maxHeight,
                          maxWidth: maxWidth,
                          idController: ref.read(idControllerProvider),
                          passwordController: ref.read(passwordControllerProvider),
                          classController: ref.read(classControllerProvider),
                          salaryController: ref.read(salaryControllerProvider),
                          qualificationController: ref.read(qualificationControllerProvider),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: currentStep > 0
                            ? () {
                                ref.read(currentStepProvider.notifier).state--;
                                ref.read(pageControllerProvider).previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              }
                            : null,
                        child: Container(
                          width: maxWidth * 0.35,
                          height: maxHeight * 0.1,
                          decoration: BoxDecoration(
                              color: currentStep > 0
                                  ? Colors.amberAccent
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Center(child: Text('Previous')),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onNextStep(context, ref),
                      child: Container(
                        width: maxWidth * 0.35,
                        height: maxHeight * 0.1,
                        decoration: BoxDecoration(
                            color: Colors.amberAccent,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Center(child: Text('Next')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
