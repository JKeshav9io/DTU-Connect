// Updated MarkAttendancePage.dart for new Firestore structure with Students List Title

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({super.key});

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedSubjectCode;
  String? selectedSubjectName;
  List<Map<String, String>> subjects = [];
  List<Map<String, String>> students = [];
  final Map<String, bool> attendanceStatus = {};

  String? branchId;
  String? sectionId;

  bool isLoading = true;
  String classStatus = 'conducted';
  String overrideStatus = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final studentQuery = await _firestore
          .collection('students')
          .where('email', isEqualTo: user.email)
          .get();
      if (studentQuery.docs.isEmpty) return;

      final studentData = studentQuery.docs.first.data();
      branchId = studentData['branchId'] as String?;
      sectionId = studentData['sectionId'] as String?;
      if (branchId == null || sectionId == null) return;

      // Fetch subjects
      final subjectsSnap = await _firestore
          .collection('branches')
          .doc(branchId)
          .collection('sections')
          .doc(sectionId)
          .collection('subjects')
          .get();

      subjects = subjectsSnap.docs.map((doc) {
        final data = doc.data();
        final code = doc.id;
        final name = (data['subjectName'] as String?) ?? code;
        return {'subjectCode': code, 'subjectName': name};
      }).toList();

      if (subjects.isNotEmpty) {
        selectedSubjectCode = subjects.first['subjectCode'];
        selectedSubjectName = subjects.first['subjectName'];
      }

      // Fetch students of the section
      final studentsSnap = await _firestore
          .collection('students')
          .where('branchId', isEqualTo: branchId)
          .where('sectionId', isEqualTo: sectionId)
          .get();

      students = studentsSnap.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] as String? ?? 'Unknown',
          'roll': data['rollNo'] as String? ?? 'N/A',
        };
      }).toList();

      for (var s in students) {
        attendanceStatus[s['id']!] = true;
      }

      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  void markAll(bool isPresent) {
    setState(() {
      classStatus = 'conducted';
      overrideStatus = isPresent ? '' : 'bunked';
      attendanceStatus.updateAll((key, value) => isPresent);
    });
  }

  void markClassCancelled() {
    setState(() {
      classStatus = 'cancelled';
      overrideStatus = 'cancelled';
      attendanceStatus.updateAll((key, value) => false);
    });
  }

  Future<void> publishAttendance() async {
    if (selectedSubjectCode == null || selectedSubjectName == null) return;

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final docId = '${selectedSubjectCode}_$dateStr';

    final batch = _firestore.batch();

    for (var student in students) {
      final id = student['id']!;
      final status = overrideStatus.isNotEmpty
          ? overrideStatus
          : (attendanceStatus[id]! ? 'present' : 'absent');

      final docRef = _firestore
          .collection('students')
          .doc(id)
          .collection('attendance')
          .doc(docId);

      batch.set(docRef, {
        'date': dateStr,
        'lectureSlotId': docId,
        'subjectCode': selectedSubjectCode,
        'subjectName': selectedSubjectName,
        'status': status,
        'held': classStatus,
        'recordedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Attendance published successfully!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Subject',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedSubjectCode,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                final subj = subjects.firstWhere((s) => s['subjectCode'] == value);
                setState(() {
                  selectedSubjectCode = subj['subjectCode'];
                  selectedSubjectName = subj['subjectName'];
                });
              },
              items: subjects
                  .map((subj) => DropdownMenuItem<String>(
                value: subj['subjectCode'],
                child: Text(subj['subjectName']!),
              ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: markClassCancelled,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Class Cancelled',
                    style: TextStyle(color: Colors.orange.shade900),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => markAll(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Class Bunked',
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // List title for students
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Student List',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: students.isEmpty
                  ? const Center(child: Text('No students found.'))
                  : ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final id = student['id']!;
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(student['name']!),
                    subtitle: Text(student['roll']!),
                    trailing: Switch(
                      value: attendanceStatus[id]!,
                      onChanged: (val) => setState(() => attendanceStatus[id] = val),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: width,
              child: ElevatedButton(
                onPressed: publishAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Publish Attendance',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
