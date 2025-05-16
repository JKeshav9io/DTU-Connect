import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> setupSubjectAssignments() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String branchId = 'MCE';
  final String sectionId = 'B05';

  final subjects = {
    'AM102': {
      'name': 'Mathematics II',
      'assignments': [
        {
          'title': 'Assignment 1 - Integration Techniques',
          'description': 'Solve Q1–Q5 from Module 2',
          'fileURL': 'https://example.com/assignments/am102_assign1.pdf',
          'dueDate': DateTime(2025, 5, 20),
        },
        {
          'title': 'Assignment 2 - Laplace Transforms',
          'description': 'Practice Laplace questions Q1–Q10',
          'fileURL': 'https://example.com/assignments/am102_assign2.pdf',
          'dueDate': DateTime(2025, 5, 27),
        },
      ],
    },
    'MC104': {
      'name': 'Discrete Mathematics',
      'assignments': [
        {
          'title': 'Assignment 1 - Combinatorics',
          'description': 'Solve all questions from Assignment Sheet 3',
          'fileURL': 'https://example.com/assignments/mc104_assign1.pdf',
          'dueDate': DateTime(2025, 5, 21),
        },
      ],
    },
    'MC102': {
      'name': 'Complex Analysis',
      'assignments': [
        {
          'title': 'Assignment 1 - Complex Numbers',
          'description': 'Complete exercises from Chapter 1',
          'fileURL': 'https://example.com/assignments/mc102_assign1.pdf',
          'dueDate': DateTime(2025, 5, 23),
        },
      ],
    },
    'CO102': {
      'name': 'Programming Fundamentals',
      'assignments': [
        {
          'title': 'Assignment 1 - C Functions',
          'description': 'Write and test recursive functions',
          'fileURL': 'https://example.com/assignments/co102_assign1.pdf',
          'dueDate': DateTime(2025, 5, 25),
        },
      ],
    },
  };

  for (final subjectCode in subjects.keys) {
    final subject = subjects[subjectCode]!;
    final assignments = subject['assignments'] as List<Map<String, dynamic>>;

    for (int i = 0; i < assignments.length; i++) {
      final assignment = assignments[i];
      final assignmentId = 'assign_${i + 1}';

      await firestore
          .collection('branches')
          .doc(branchId)
          .collection('sections')
          .doc(sectionId)
          .collection('subjects')
          .doc(subjectCode)
          .collection('assignments')
          .doc(assignmentId)
          .set({
        'title': assignment['title'],
        'description': assignment['description'],
        'fileURL': assignment['fileURL'],
        'postedAt': FieldValue.serverTimestamp(),
        'dueDate': assignment['dueDate'],
      });

      print('✅ Added $assignmentId for $subjectCode');
    }
  }

  print('🎉 All dummy assignments added!');
}
