import 'package:flutter/material.dart';
import 'package:school_management/models/student.dart';

class StudentTile extends StatefulWidget {
  final Student student;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const StudentTile({
    super.key,
    required this.student,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<StudentTile> createState() => _StudentTileState();
}

class _StudentTileState extends State<StudentTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: ExpansionTile(
        key: PageStorageKey(widget.student.rollNo),
        leading: widget.student.studentPic != null
            ? ClipOval(
                child: Image.network(
                  widget.student.studentPic!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, size: 50),
                ),
              )
            : const CircleAvatar(
                radius: 25,
                child: Icon(Icons.person),
              ),
        title: Text(
          widget.student.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text('Roll No: ${widget.student.rollNo}'),
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: isExpanded
              ? SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 5,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: widget.onDelete,
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: IconButton(
                          icon: const Icon(Icons.update, color: Colors.blue),
                          onPressed: widget.onUpdate,
                        ),
                      ),
                    ],
                  ),
                )
              : const Icon(Icons.arrow_forward_ios, key: ValueKey("arrow")),
        ),
        onExpansionChanged: (value) {
          setState(() {
            isExpanded = value; // Update the expansion state
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Class: ${widget.student.className}'),
                  Text('Father Name: ${widget.student.fatherName}'),
                  Text('Mother Name: ${widget.student.motherName}'),
                  Text('Contact: ${widget.student.fatherPhone}'),
                  Text('Cnic: ${widget.student.cnic}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
