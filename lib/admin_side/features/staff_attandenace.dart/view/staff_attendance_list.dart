import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:school_management/admin_side/features/staff_attandenace.dart/controller/staff_attendance_controller.dart';

class StaffAttendanceList extends ConsumerStatefulWidget {
  const StaffAttendanceList({super.key});

  @override
  ConsumerState<StaffAttendanceList> createState() => _StaffAttendanceListState();
}

class _StaffAttendanceListState extends ConsumerState<StaffAttendanceList> {
  DateTime selectedDate = DateTime.now();

  String get formattedDate => DateFormat('yyyy-MM-dd').format(selectedDate);

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  void fetchAttendance() {
    ref.read(attendanceProvider.notifier).fetchAttendance(formattedDate);
  }

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
      fetchAttendance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceList = ref.watch(attendanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Attendance'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: pickDate,
          ),
        ],
      ),
      body: attendanceList.isEmpty
          ? const Center(child: Text('No attendance data available.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: attendanceList.length,
              itemBuilder: (context, index) {
                final item = attendanceList[index];

                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.attendanceMarked ? Colors.green : Colors.red,
                      child: Icon(
                        item.attendanceMarked ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      "Staff ID: ${item.staffId}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date: ${item.date}", style: const TextStyle(fontSize: 14.0)),
                        Text("Time: ${item.time ?? 'N/A'}", style: const TextStyle(fontSize: 14.0)),
                      ],
                    ),
                    trailing: Switch(
                      value: item.attendanceMarked,
                      onChanged: (newValue) {
                        ref
                            .read(attendanceProvider.notifier)
                            .updateAttendance(item.staffId, newValue, item.date);
                      },
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
