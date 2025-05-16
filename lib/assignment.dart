import 'package:flutter/material.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  @override
  Widget build(BuildContext context) {
    final assignments = <Map<String, String>>[
      {'subjectName': 'Mathematics II', 'dueDate': '20/03/2025', 'status': 'Overdue', 'subjectCode': 'AM102'},
      {'subjectName': 'Discrete Structures', 'dueDate': '11/05/2025', 'status': 'Due Today', 'subjectCode': 'MC102'},
      {'subjectName': 'Complex Analysis', 'dueDate': '25/05/2025', 'status': 'Upcoming', 'subjectCode': 'MC104'},
      {'subjectName': 'Programming Fundamentals', 'dueDate': '30/05/2025', 'status': 'Upcoming', 'subjectCode': 'CS101'},
    ];

    final overdueCount = assignments.where((a) => a['status'] == 'Overdue').length.toString();
    final dueTodayCount = assignments.where((a) => a['status'] == 'Due Today').length.toString();
    final upcomingCount = assignments.where((a) => a['status'] == 'Upcoming').length.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assignments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DueCards(overDue: overdueCount, dueToday: dueTodayCount, upcoming: upcomingCount),
            const SizedBox(height: 20),
            ...assignments.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: AssignmentCard(
                subjectName: a['subjectName']!,
                dueDate: a['dueDate']!,
                status: a['status']!,
                subjectCode: a['subjectCode']!,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class DueCards extends StatelessWidget {
  final String overDue;
  final String dueToday;
  final String upcoming;

  const DueCards({super.key, required this.overDue, required this.dueToday, required this.upcoming});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _dueCard(title: 'Overdue', value: overDue, color: Colors.red.shade100, textColor: Colors.red.shade800),
        _dueCard(title: 'Due Today', value: dueToday, color: Colors.orange.shade100, textColor: Colors.orange.shade800),
        _dueCard(title: 'Upcoming', value: upcoming, color: Colors.green.shade100, textColor: Colors.green.shade800),
      ],
    );
  }

  Widget _dueCard({required String title, required String value, required Color color, required Color textColor}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }
}

class AssignmentCard extends StatelessWidget {
  final String subjectName;
  final String dueDate;
  final String status;
  final String subjectCode;

  const AssignmentCard({super.key, required this.subjectName, required this.dueDate, required this.status, required this.subjectCode});

  void _showDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text('Subject: $subjectName\nCode: $subjectCode\nDue: $dueDate\nStatus: $status'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(subjectName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(status, style: TextStyle(color: status == 'Overdue' ? Colors.red : Colors.green)),
              ],
            ),
            const SizedBox(height: 5),
            Text('Due Date: $dueDate', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showDialog(context, 'Submit'),
                    child: const Text('Submit'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showDialog(context, 'Details'),
                    child: const Text('Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}