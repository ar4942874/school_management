import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_management/staff_side/features/leave_management.dart/controller/leave_management_controller.dart';
import 'package:school_management/staff_side/features/leave_management.dart/model/leave_request.dart';

class LeaveManagementPage extends ConsumerStatefulWidget {
  const LeaveManagementPage({super.key});
  static const String pageName = '/leave-management-page';

  @override
  ConsumerState<LeaveManagementPage> createState() =>
      _LeaveManagementPageState();
}

class _LeaveManagementPageState extends ConsumerState<LeaveManagementPage> {
  final TextEditingController reasonController = TextEditingController();
  DateTime? selectedDate;

  // Function to handle leave request submission
  Future<void> handleSubmit() async {
    if (selectedDate == null || reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    final newRequest = LeaveRequest(
      id: '', // Firestore will generate an ID
      date: selectedDate!,
      reason: reasonController.text,
      status: 'Pending',
    );

    try {
      await ref
          .read(leaveManagementProvider.notifier)
          .submitLeaveRequest(newRequest);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Leave request submitted successfully.")),
      );

      // Reset the form
      setState(() {
        selectedDate = null;
        reasonController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // Function to format date
  String formatDate(DateTime? date) {
    if (date == null) return "Tap to select a date";
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final leaveRequests = ref.watch(leaveManagementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Management"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Select Date
            const Text(
              "Select Date:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDate(selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section: Reason for Leave
            const Text(
              "Reason for Leave:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter reason",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: handleSubmit,
                child: const Text("Request Leave"),
              ),
            ),
            const SizedBox(height: 24),

            // Section: Request Status
            const Text(
              "Leave Requests:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: leaveRequests.isEmpty
                  ? const Center(child: Text("No leave requests found."))
                  : ListView.builder(
                      itemCount: leaveRequests.length,
                      itemBuilder: (context, index) {
                        final request = leaveRequests[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text("Date: ${request.date}"),
                            subtitle: Text("Reason: ${request.reason}"),
                            trailing: Text(
                              request.status,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: request.status == "Pending"
                                    ? Colors.orange
                                    : request.status == "Approved"
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
