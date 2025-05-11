import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AcademicPerformanceScreen extends StatefulWidget {
  const AcademicPerformanceScreen({super.key});

  @override
  State<AcademicPerformanceScreen> createState() =>
      _AcademicPerformanceScreenState();
}

class _AcademicPerformanceScreenState extends State<AcademicPerformanceScreen> {
  final double cgpa = 8.7;

  final Map<String, dynamic> hardcodedData = {
    "CO102": {
      "subject_name": "Programming Fundamentals",
      "class_tests": {"test1": 9, "test2": 8},
      "mid_sem": 23,
      "end_sem": 40,
      "gpa": 9.0,
      "grade": "A"
    },
    "MA101": {
      "subject_name": "Mathematics-I",
      "class_tests": {"test1": 7, "test2": 6},
      "mid_sem": 20,
      "end_sem": 35,
      "gpa": 8.0,
      "grade": "B+"
    },
    "PH101": {
      "subject_name": "Physics",
      "class_tests": {"test1": 8, "test2": 9},
      "mid_sem": 24,
      "end_sem": 42,
      "gpa": 9.5,
      "grade": "A+"
    }
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Academic Performance"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          PerformanceCard(cgpa: cgpa),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: hardcodedData.length,
            itemBuilder: (context, index) {
              final subjectCode = hardcodedData.keys.elementAt(index);
              final subjectData = hardcodedData[subjectCode];

              final subjectName = subjectCode.toUpperCase() == "CO102"
                  ? "Programming Fundamentals"
                  : subjectData['subject_name'] ?? subjectCode;

              final int test1 =
                  (subjectData['class_tests']?['test1'] as num?)?.toInt() ?? 0;
              final int test2 =
                  (subjectData['class_tests']?['test2'] as num?)?.toInt() ?? 0;
              final int classTest = test1 + test2;

              final int midSem = (subjectData['mid_sem'] as num?)?.toInt() ?? 0;
              final int endSem = (subjectData['end_sem'] as num?)?.toInt() ?? 0;

              final subjectGpa = subjectData['gpa'];
              final subjectGrade = subjectData['grade'];

              return SubjectCard(
                subjectName: subjectName,
                code: subjectCode,
                classTest: classTest,
                midSem: midSem,
                endSem: endSem,
                subjectGpa: subjectGpa,
                subjectGrade: subjectGrade,
              );
            },
          ),
        ],
      ),
    );
  }
}

class PerformanceCard extends StatelessWidget {
  final double cgpa;
  const PerformanceCard({super.key, required this.cgpa});

  @override
  Widget build(BuildContext context) {
    final progress = (cgpa / 10).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Current Semester",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CircularPercentIndicator(
              radius: 50.0,
              lineWidth: 6,
              percent: progress,
              center: Text(
                "${cgpa.toStringAsFixed(1)} SGPA",
                style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              progressColor: Colors.blue,
              backgroundColor: Colors.grey[300]!,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectCard extends StatelessWidget {
  final String subjectName;
  final String code;
  final int classTest;
  final int midSem;
  final int endSem;
  final dynamic subjectGpa;
  final dynamic subjectGrade;

  const SubjectCard({
    super.key,
    required this.subjectName,
    required this.code,
    required this.classTest,
    required this.midSem,
    required this.endSem,
    required this.subjectGpa,
    required this.subjectGrade,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subjectName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(code, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      subjectGpa != null ? "GPA: $subjectGpa" : "GPA: N/A",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subjectGrade != null
                          ? "Grade: $subjectGrade"
                          : "Grade: N/A",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ScoreCard("Class Test", classTest, "Class Test"),
                ScoreCard("Mid-Sem", midSem, "Mid Sem"),
                ScoreCard("End-Sem", endSem, "End Sem"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ScoreCard extends StatelessWidget {
  final String title;
  final int score;
  final String name;

  const ScoreCard(this.title, this.score, this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  title == "Class Test"
                      ? Icons.edit
                      : title == "Mid-Sem"
                      ? Icons.book
                      : Icons.school,
                  size: 24,
                ),
                const SizedBox(height: 5),
                Text(name,
                    style: const TextStyle(color: Colors.grey, fontSize: 15)),
                const SizedBox(height: 5),
                Text("$score",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
