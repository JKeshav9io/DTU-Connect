import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dtu_connect_2/add_assignment.dart';
import 'package:intl/intl.dart';

import 'edit_assignment.dart';

class ManageAssignment extends StatefulWidget {
  const ManageAssignment({super.key});

  @override
  State<ManageAssignment> createState() => _ManageAssignmentState();
}

class _ManageAssignmentState extends State<ManageAssignment> {
  List<Map<String, String>> subjects = [];
  String selectedSubjectCode = '';
  Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> assignmentCache = {};
  bool isLoadingSubjects = true;
  bool isLoadingAssignments = false;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    setState(() => isLoadingSubjects = true);
    final snapshot = await FirebaseFirestore.instance
        .collection('branches')
        .doc('MCE')
        .collection('sections')
        .doc('B05')
        .collection('subjects')
        .get();

    subjects = snapshot.docs
        .map((doc) => {
      'code': doc['subjectCode'] as String,
      'name': doc['subjectName'] as String,
    })
        .toList();

    if (subjects.isNotEmpty) {
      selectedSubjectCode = subjects.first['code']!;
      await _fetchAssignmentsFor(selectedSubjectCode);
    }
    setState(() => isLoadingSubjects = false);
  }

  Future<void> _fetchAssignmentsFor(String code) async {
    setState(() => isLoadingAssignments = true);
    final snapshot = await FirebaseFirestore.instance
        .collection('branches')
        .doc('MCE')
        .collection('sections')
        .doc('B05')
        .collection('subjects')
        .doc(code)
        .collection('assignments')
        .get();

    assignmentCache[code] = snapshot.docs;
    setState(() => isLoadingAssignments = false);
  }

  String _getStatus(bool isSubmitted, DateTime dueDate) {
    if (isSubmitted) return 'Submitted';
    final now = DateTime.now();
    if (dueDate.isBefore(now)) return 'Overdue';
    if (dueDate.difference(now).inDays == 0) return 'Due Today';
    return 'Upcoming';
  }

  @override
  Widget build(BuildContext context) {
    final docs = assignmentCache[selectedSubjectCode] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Assignments'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (_) => const AssignmentForm(),
            ))
                .then((_) => _fetchAssignmentsFor(selectedSubjectCode)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Subject:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (isLoadingSubjects)
              const Center(child: CircularProgressIndicator())
            else
              _buildSubjectDropdown(),
            const SizedBox(height: 20),
            Expanded(child: _buildAssignmentList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedSubjectCode,
          onChanged: (code) async {
            if (code == null) return;
            setState(() => selectedSubjectCode = code);
            await _fetchAssignmentsFor(code);
          },
          items: subjects.map((subj) {
            return DropdownMenuItem<String>(
              value: subj['code'],
              child: Text(subj['name']!),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAssignmentList() {
    final docs = assignmentCache[selectedSubjectCode] ?? [];
    if (isLoadingAssignments) {
      return const Center(child: CircularProgressIndicator());
    }
    if (docs.isEmpty) {
      return const Center(
        child: Text(
          'No assignments available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data();
        final raw = data['dueDate'];
        final due = raw is Timestamp ? raw.toDate() : DateTime.tryParse(raw.toString()) ?? DateTime.now();
        final formatted = DateFormat('dd MMM yyyy').format(due);
        final isSubmitted = data['isSubmitted'] ?? false;
        final status = _getStatus(isSubmitted, due);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: AssignCard(
            docId: doc.id,
            subjectCode: selectedSubjectCode,
            title: data['title'] ?? 'Untitled',
            description: data['description'] ?? '-',
            dueDate: formatted,
            status: status,
            submitted: isSubmitted,
            rawData: data,
          ),
        );
      },
    );
  }
}

class AssignCard extends StatelessWidget {
  final String docId;
  final String subjectCode;
  final String title;
  final String description;
  final String dueDate;
  final String status;
  final bool submitted;
  final Map<String, dynamic> rawData;

  const AssignCard({
    super.key,
    required this.docId,
    required this.subjectCode,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.submitted,
    required this.rawData,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Overdue':
        return Colors.red.shade400;
      case 'Due Today':
        return Colors.orange.shade400;
      case 'Upcoming':
        return Colors.green.shade400;
      case 'Submitted':
        return Colors.blue.shade400;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                      builder: (_) => EditAssignmentForm(
                        branchId: 'MCE',
                        sectionId: 'B05',
                        subjectCode: subjectCode,
                        docId: docId,
                        initialData: rawData,
                      ),
                    ))
                        .then((_) => context.findAncestorStateOfType<_ManageAssignmentState>()
                        ?._fetchAssignmentsFor(subjectCode));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Due: $dueDate',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
