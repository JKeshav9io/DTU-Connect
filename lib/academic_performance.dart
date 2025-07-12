import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AcademicPerformanceScreen extends StatefulWidget {
  final String studentId;

  const AcademicPerformanceScreen({super.key, required this.studentId});

  @override
  State<AcademicPerformanceScreen> createState() => _AcademicPerformanceScreenState();
}

class _AcademicPerformanceScreenState extends State<AcademicPerformanceScreen> {
  int? selectedSemester;
  List<int> availableSemesters = [];
  Map<String, dynamic>? performanceData;
  Map<String, dynamic> subjectsData = {};
  Map<String, dynamic> studentData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .get();

      setState(() {
        studentData = studentDoc.data() ?? {};
        selectedSemester = studentData['semester'] as int? ?? 1;
      });

      final performanceSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('performance')
          .get();

      setState(() {
        availableSemesters = performanceSnapshot.docs
            .map((doc) => int.tryParse(doc.id) ?? 0)
            .where((sem) => sem > 0)
            .toList()
          ..sort();
      });

      if (selectedSemester != null) {
        await _loadSemesterData(selectedSemester!);
      }
    } catch (e) {
      debugPrint("Error fetching initial data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadSemesterData(int semester) async {
    setState(() => isLoading = true);

    try {
      final performanceDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('performance')
          .doc(semester.toString())
          .get();

      final subjectsSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('performance')
          .doc(semester.toString())
          .collection('subjects')
          .get();

      debugPrint("Performance data: ${performanceDoc.data()}");
      debugPrint("Subjects data: ${subjectsSnapshot.docs.map((e) => e.data()).toList()}");

      setState(() {
        performanceData = performanceDoc.data();
        subjectsData = {
          for (var doc in subjectsSnapshot.docs) doc.id: doc.data()
        };
      });
    } catch (e) {
      debugPrint("Error loading semester data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Academic Performance"),
        centerTitle: true,
        actions: [
          if (availableSemesters.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedSemester,
                  icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onPrimary),
                  dropdownColor: theme.colorScheme.primary,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary),
                  onChanged: (int? newValue) {
                    if (newValue != null && newValue != selectedSemester) {
                      setState(() => selectedSemester = newValue);
                      _loadSemesterData(newValue);
                    }
                  },
                  items: availableSemesters.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text("Semester $value"),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (isLoading) return _buildLoadingState();
    if (subjectsData.isEmpty) return _buildEmptyState(theme);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildPerformanceSummaryCard(theme),
        const SizedBox(height: 16),
        ...subjectsData.entries.map((entry) {
          final subjectCode = entry.key;
          final subjectData = entry.value;

          return _buildSubjectCard(
            theme: theme,
            subjectCode: subjectCode,
            subjectData: subjectData,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPerformanceSummaryCard(ThemeData theme) {
    final cgpa = performanceData?['cgpa']?.toDouble() ?? 0.0;
    final sgpa = performanceData?['sgpa']?.toDouble() ?? 0.0;
    final progress = (sgpa / 10).clamp(0.0, 1.0);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Current Semester", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildPerformanceRow(theme, "CGPA", cgpa.toStringAsFixed(2)),
                  _buildPerformanceRow(theme, "SGPA", sgpa.toStringAsFixed(2)),
                  _buildPerformanceRow(theme, "University Rank", "#${performanceData?['universityRank'] ?? 'N/A'}"),
                  _buildPerformanceRow(theme, "Branch Rank", "#${performanceData?['branchRank'] ?? 'N/A'}"),
                ],
              ),
            ),
            const SizedBox(width: 16),
            CircularPercentIndicator(
              radius: MediaQuery.of(context).size.width * 0.12,
              lineWidth: 6,
              percent: progress,
              center: Text(
                "${sgpa.toStringAsFixed(1)} SGPA",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              progressColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceVariant,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard({
    required ThemeData theme,
    required String subjectCode,
    required Map<String, dynamic> subjectData,
  }) {
    final ct1 = subjectData['ct1'] as int? ?? 0;
    final ct2 = subjectData['ct2'] as int? ?? 0;
    final midSem = subjectData['midSem'] as int? ?? 0;
    final endSem = subjectData['endSem'] as int? ?? 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // First row: Subject Name and GPA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    subjectData['subjectName'] ?? subjectCode,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "GPA: ${subjectData['gpa']?.toStringAsFixed(1) ?? 'N/A'}",
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Second row: Subject Code and Grade
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    subjectCode,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  ),
                ),
                Text(
                  "Grade: ${subjectData['grade'] ?? 'N/A'}",
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildScoreCard(theme, "Class Test", ct1 + ct2, Icons.edit),
                _buildScoreCard(theme, "Mid-Sem", midSem, Icons.book),
                _buildScoreCard(theme, "End-Sem", endSem, Icons.school),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildScoreCard(ThemeData theme, String title, int score, IconData icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              children: [
                Icon(icon, size: 22, color: theme.colorScheme.primary),
                const SizedBox(height: 4),
                Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text("$score", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Text("$label: ", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          Flexible(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text("No academic records found", style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          TextButton(onPressed: _fetchInitialData, child: const Text("Retry")),
        ],
      ),
    );
  }
}
