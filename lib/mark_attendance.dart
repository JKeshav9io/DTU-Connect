import 'package:flutter/material.dart';

class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({super.key});

  @override
  _MarkAttendancePageState createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  String selectedSubject = "Discrete Structures";
  final List<String> subjects = [
    "Discrete Structures",
    "Complex Analysis",
    "Mathematics II",
    "Data Structures",
    "Operating Systems"
  ];

  // Hardcoded student list
  final List<Map<String, String>> students = [
    {'id': 's1', 'name': 'Alice', 'roll': '101'},
    {'id': 's2', 'name': 'Bob', 'roll': '102'},
    {'id': 's3', 'name': 'Charlie', 'roll': '103'},
    {'id': 's4', 'name': 'Diana', 'roll': '104'},
    {'id': 's5', 'name': 'Eve', 'roll': '105'},
  ];

  Map<String, bool> attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    // Initialize attendanceStatus defaults to present
    for (var student in students) {
      attendanceStatus[student['id']!] = true;
    }
  }

  void markAll(bool isPresent) {
    setState(() {
      attendanceStatus.updateAll((key, value) => isPresent);
    });
  }

  void markClassCancelled() {
    // For UI stub, just reset statuses
    setState(() {
      attendanceStatus.updateAll((key, value) => false);
    });
  }

  void publishAttendance() {
    // Stub: show confirmation
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Attendance Published'),
        content: const Text('Attendance has been recorded successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mark Attendance",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Subject", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  value: selectedSubject,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSubject = newValue!;
                    });
                  },
                  items: subjects.map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 16)),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => markAll(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      "Class Cancelled",
                      style: TextStyle(color: Colors.green.shade900),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => markAll(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      "Class Bunked",
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final id = student['id']!;
                  final isPresent = attendanceStatus[id] ?? false;
                  return StudentCard(
                    studentName: student['name']!,
                    rollNo: student['roll']!,
                    isPresent: isPresent,
                    onMark: (value) {
                      setState(() {
                        attendanceStatus[id] = value;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: publishAttendance,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Center(
                child: Text("Publish Attendance", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final String studentName;
  final String rollNo;
  final bool isPresent;
  final Function(bool) onMark;

  const StudentCard({
    super.key,
    required this.studentName,
    required this.rollNo,
    required this.isPresent,
    required this.onMark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 30, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(studentName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Roll No: $rollNo", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => onMark(true),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPresent ? Colors.green.shade700 : Colors.green.shade300,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onMark(false),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: !isPresent ? Colors.red.shade700 : Colors.red.shade300,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}