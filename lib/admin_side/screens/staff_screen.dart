import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_management/admin_side/screens/add_staff.dart';
import 'package:school_management/admin_side/screens/shimmer_loading.dart';
import 'package:school_management/staff_side/features/dashboard/model/staff.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  _StaffScreenState createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  late String currentUserUid;

  @override
  void initState() {
    super.initState();
    currentUserUid = firebaseAuth.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0.5,
      ),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search Staff',
                  hintText: 'Enter name or qualification',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('staff')
                      .where('adminId', isEqualTo: currentUserUid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ShimmerLoading();
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No staff found.'));
                    }

                    final staffList = snapshot.data!.docs
                        .map((doc) => StaffData.fromMap(
                            doc.data() as Map<String, dynamic>))
                        .where((staff) {
                      final name = staff.staffName.toLowerCase();
                      final qualification = staff.qualification.toLowerCase();
                      return name.contains(_searchQuery) ||
                          qualification.contains(_searchQuery);
                    }).toList();

                    if (staffList.isEmpty) {
                      return const Center(
                          child: Text('No matching staff found.'));
                    }

                    return ListView.builder(
                      itemCount: staffList.length,
                      itemBuilder: (context, index) {
                        final staff = staffList[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              staff.staffName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Qualification: ${staff.qualification}'),
                                Text('Class assigned: ${staff.staffClass}'),
                                Text('Salary: ${staff.salary}'),
                                Text('Join Date: ${staff.joinDate}'),
                              ],
                            ),
                            trailing: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Delete Button
                                  Expanded(
                                    flex: 5,
                                    child: IconButton(
                                      onPressed: () => _showDeleteConfirmation(
                                          context, staff),
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                    ),
                                  ),

                                  // Update Button
                                  Expanded(
                                    flex: 5,
                                    child: IconButton(
                                      onPressed: () =>
                                          _showUpdateDialog(context, staff),
                                      icon: const Icon(Icons.update),
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AddStaff.pageName),
                child: Container(
                  width: 70,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue.withOpacity(0.4)),
                  child: const Column(
                    children: [
                      Icon(Icons.add),
                      FittedBox(child: Text('Add Staff'))
                    ],
                  ),
                ),
              )),
        )
      ]),
    );
  }
}

void _showDeleteConfirmation(BuildContext context, StaffData staff) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${staff.staffName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Delete staff from Firestore
                await FirebaseFirestore.instance
                    .collection('staff')
                    .doc(staff.id)
                    .delete();

                Navigator.of(context).pop(); // Close the dialog

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(milliseconds: 1500),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Deleted!',
                      message: '${staff.staffName} has been removed.',
                      contentType: ContentType.failure,
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    duration: Duration(milliseconds: 1500),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Error',
                      message: 'Failed to delete staff. Try again.',
                      contentType: ContentType.failure,
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}

void _showUpdateDialog(BuildContext context, StaffData staff) {
  final TextEditingController nameController =
      TextEditingController(text: staff.staffName);
  final TextEditingController qualificationController =
      TextEditingController(text: staff.qualification);
  final TextEditingController salaryController =
      TextEditingController(text: staff.salary);
  final TextEditingController classController =
      TextEditingController(text: staff.staffClass);
  final TextEditingController genderController =
      TextEditingController(text: staff.gender);
  final TextEditingController textNumberController =
      TextEditingController(text: staff.textNumber);
  final TextEditingController whatsappController =
      TextEditingController(text: staff.whatsapp);
  final TextEditingController addressController =
      TextEditingController(text: staff.address);
  final TextEditingController passwordController =
      TextEditingController(text: staff.password);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Update Staff'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: qualificationController,
                decoration: const InputDecoration(labelText: 'Qualification'),
              ),
              TextField(
                controller: salaryController,
                decoration: const InputDecoration(labelText: 'Salary'),
              ),
              TextField(
                controller: classController,
                decoration: const InputDecoration(labelText: 'Class Assigned'),
              ),
              TextField(
                controller: genderController,
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              TextField(
                controller: textNumberController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
              ),
              TextField(
                controller: whatsappController,
                decoration: const InputDecoration(labelText: 'WhatsApp'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final updatedStaff = StaffData(
                  id: staff.id,
                  adminId: staff.adminId,
                  staffName: nameController.text,
                  qualification: qualificationController.text,
                  salary: salaryController.text,
                  staffClass: classController.text,
                  gender: genderController.text,
                  textNumber: textNumberController.text,
                  whatsapp: whatsappController.text,
                  address: addressController.text,
                  password: passwordController.text,
                  joinDate: staff.joinDate, // Keep original join date
                );

                // Update Firestore using the toMap() method
                final QuerySnapshot query = await FirebaseFirestore.instance
                    .collection('staff')
                    .where('id', isEqualTo: staff.id)
                    .get();

                for (var doc in query.docs) {
                  await doc.reference.update(updatedStaff.toMap());
                }

                Navigator.of(context).pop(); // Close the dialog

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(milliseconds: 1500),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Updated!',
                      message: '${updatedStaff.staffName} has been updated.',
                      contentType: ContentType.success,
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    duration: Duration(milliseconds: 1500),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Error',
                      message: 'Failed to update staff. Try again.',
                      contentType: ContentType.failure,
                    ),
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
}
