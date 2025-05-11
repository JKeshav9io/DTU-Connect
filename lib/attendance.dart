import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  late final Map<String, dynamic> studentData;

  @override
  void initState() {
    super.initState();
    // Hardcoded student attendance data
    studentData = {
      'attendance': {
        'Overall': {
          'total_classes': 40,
          'attended_classes': 32,
        },
        'MATH101': {
          'subject_name': 'Mathematics I',
          'total_classes': 12,
          'attended': 10,
        },
        'PHY102': {
          'subject_name': 'Physics II',
          'total_classes': 10,
          'attended': 8,
        },
        'CS103': {
          'subject_name': 'Introduction to Programming',
          'total_classes': 18,
          'attended': 14,
        },
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final attendanceData = studentData['attendance'] as Map<String, dynamic>?;

    if (attendanceData == null) {
      return const Scaffold(
        body: Center(child: Text("No attendance data available")),
      );
    }

    final overallData = attendanceData['Overall'] as Map<String, dynamic>?;
    var subjectsData = Map<String, dynamic>.from(attendanceData);
    subjectsData.remove('Overall');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (overallData != null)
              OverallAttendanceCard(
                totalClasses: overallData['total_classes'].toString(),
                attendedClasses: overallData['attended_classes'].toString(),
                percentage: (overallData['attended_classes'] / overallData['total_classes']).toString(),
              ),
            const SizedBox(height: 20),
            ...subjectsData.entries.map((entry) {
              final subjectCode = entry.key;
              final subject = entry.value as Map<String, dynamic>;
              int total = subject['total_classes'];
              int attended = subject['attended'];
              double percent = total > 0 ? attended / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: SubjectCard(
                  subjectName: subject['subject_name'] ?? subjectCode,
                  subjectCode: subjectCode,
                  attendancePercent: percent,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class OverallAttendanceCard extends StatelessWidget {
  final String totalClasses;
  final String attendedClasses;
  final String percentage;

  const OverallAttendanceCard({
    super.key,
    required this.totalClasses,
    required this.attendedClasses,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    int total = int.tryParse(totalClasses) ?? 0;
    int attended = int.tryParse(attendedClasses) ?? 0;
    double percent = double.tryParse(percentage) ?? 0.0;
    int missed = total - attended;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 50,
              lineWidth: 8,
              percent: percent.clamp(0.0, 1.0),
              center: Text("${(percent * 100).toStringAsFixed(1)}%"),
              progressColor: percent < 0.75 ? Colors.orange : Colors.green,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Overall Attendance",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Classes:", style: TextStyle(fontWeight: FontWeight.w500)),
                      Text("$total"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Attended:", style: TextStyle(fontWeight: FontWeight.w500)),
                      Text("$attended"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Missed:", style: TextStyle(fontWeight: FontWeight.w500)),
                      Text("$missed"),
                    ],
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

class SubjectCard extends StatelessWidget {
  final String subjectName;
  final String subjectCode;
  final double attendancePercent;

  const SubjectCard({
    super.key,
    required this.subjectName,
    required this.subjectCode,
    required this.attendancePercent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subjectName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${(attendancePercent * 100).toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: attendancePercent < 0.75 ? Colors.orange : Colors.green,
                  ),
                )
              ],
            ),
            Text(
              subjectCode,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: attendancePercent,
              backgroundColor: Colors.grey.shade300,
              color: attendancePercent < 0.75 ? Colors.orange : Colors.green,
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
}