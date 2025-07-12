import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateMarksPage extends StatefulWidget {
  const UpdateMarksPage({super.key});

  @override
  State<UpdateMarksPage> createState() => _UpdateMarksPageState();
}

class _UpdateMarksPageState extends State<UpdateMarksPage> {
  String? selectedSubject;
  String? selectedExamType;

  List<Map<String, String>> subjects = [];
  final List<String> examTypes = ["MTE", "ETE", "Class Test 1", "Class Test 2"];

  List<QueryDocumentSnapshot<Map<String, dynamic>>> students = [];
  bool isLoading = true;

  final Map<String, TextEditingController> _marksControllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load subjects
      final subSnap = await FirebaseFirestore.instance
          .collection('branches')
          .doc('MCE')
          .collection('sections')
          .doc('B05')
          .collection('subjects')
          .get();

      subjects = subSnap.docs
          .map((doc) => {
        'code': doc['subjectCode'] as String,
        'name': doc['subjectName'] as String,
      })
          .toList();

      if (subjects.isNotEmpty) selectedSubject = subjects.first['code'];
      if (examTypes.isNotEmpty) selectedExamType = examTypes.first;

      // Load students
      final stuSnap = await FirebaseFirestore.instance
          .collection('students')
          .where('branchId', isEqualTo: 'MCE')
          .where('sectionId', isEqualTo: 'B05')
          .where('enrolledYear', isEqualTo: 2024)
          .get();

      students = stuSnap.docs;

      // Initialize controllers
      for (var doc in students) {
        _marksControllers[doc.id] = TextEditingController();
      }

      setState(() => isLoading = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
      );
      setState(() => isLoading = false);
    }
  }

  Widget _buildMarksField(ThemeData theme, String studentId) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 60, maxWidth: 100),
      child: IntrinsicWidth(
        child: SizedBox(
          height: 48,
          child: TextField(
            controller: _marksControllers[studentId],
            decoration: InputDecoration(
              hintText: 'Marks',
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfo(Map<String, dynamic> data, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data['name'] ?? '-', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Roll No: ${data['rollNo'] ?? '-'}',
            style: theme.textTheme.bodySmall),
        Text('Semester: ${data['semester'] ?? '-'}',
            style: theme.textTheme.bodySmall),
      ],
    );
  }

  Future<void> _publishMarks() async {
    if (selectedSubject == null || selectedExamType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select subject and exam type')),
      );
      return;
    }

    final examField = selectedExamType == 'MTE'
        ? 'midSem'
        : selectedExamType == 'ETE'
        ? 'endSem'
        : selectedExamType == 'Class Test 1'
        ? 'ct1'
        : selectedExamType == 'Class Test 2'
        ? 'ct2'
        : null;

    if (examField == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid exam type')),
      );
      return;
    }

    final batch = FirebaseFirestore.instance.batch();
    int updatesCount = 0;

    for (var doc in students) {
      final data = doc.data();
      final studentDocId = doc.id;
      final rollNo = data['rollNo'];
      final semester = data['semester'];

      if (rollNo == null || semester == null) continue;

      final txt = _marksControllers[doc.id]?.text;
      if (txt == null || txt.isEmpty) continue;

      final marks = int.tryParse(txt);
      if (marks == null || marks < 0 || marks > 100) continue;

      // Update in student's performance subcollection
      final studentSubjectRef = FirebaseFirestore.instance
          .collection('students')
          .doc(studentDocId)
          .collection('performance')
          .doc(semester.toString())
          .collection('subjects')
          .doc(selectedSubject);

      batch.set(studentSubjectRef, {
        'subjectCode': selectedSubject,
        examField: marks,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      updatesCount++;
    }

    if (updatesCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid marks to update')),
      );
      return;
    }

    try {
      await batch.commit();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully updated $updatesCount records')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating marks: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Marks', style: theme.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject Dropdown
                Text('Subject', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedSubject,
                      onChanged: (val) => setState(() => selectedSubject = val),
                      items: subjects
                          .map((subj) => DropdownMenuItem(
                        value: subj['code'],
                        child: Text(subj['name']!),
                      ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Exam Type Selection
                Text('Exam Type', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: examTypes.map((type) {
                      final sel = selectedExamType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: sel,
                          onSelected: (_) => setState(() => selectedExamType = type),
                          selectedColor: theme.primaryColor,
                          showCheckmark: false,
                          backgroundColor: theme.cardColor,
                          labelStyle: TextStyle(
                            color: sel
                                ? Colors.white
                                : theme.textTheme.bodyLarge!.color,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Students List
                ...students.map((doc) {
                  final data = doc.data();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Expanded(child: _buildStudentInfo(data, theme)),
                              const SizedBox(width: 16),
                              _buildMarksField(theme, doc.id),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24),

                // Centered and Expanded Publish Button
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: ElevatedButton(
                        onPressed: _publishMarks,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Publish Marks'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _marksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}