import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> fetchStudentData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final email = user.email!;

    final query = await _firestore
        .collection('students')
        .where('email', isEqualTo: email)
        .get();
    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    final data = doc.data();

    // Attendance
    final attSnap = await doc.reference.collection('attendance').get();
    final attendance = attSnap.docs
        .map((d) => {'id': d.id, ...d.data()})
        .toList();

    // Performance
    final perfSnap = await doc.reference.collection('performance').get();
    final performance = <Map<String, dynamic>>[];
    for (var semDoc in perfSnap.docs) {
      final subjSnap = await semDoc.reference.collection('subjects').get();
      final subjects = subjSnap.docs
          .map((s) => {'subjectCode': s.id, ...s.data()})
          .toList();
      performance.add({
        'semesterId': semDoc.id,
        ...semDoc.data(),
        'subjects': subjects,
      });
    }

    return {
      ...data,
      'attendance': attendance,
      'performance': performance,
    };
  }
}
