import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? selectedSubject;
  String selectedNotice = "Class Bunk";
  final TextEditingController customMessageController = TextEditingController();
  final TextEditingController customTitleController = TextEditingController();
  final TextEditingController defaultMessageController = TextEditingController();

  List<Map<String, dynamic>> subjects = [];
  bool isLoading = true;
  PlatformFile? pickedFile;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final email = user.email;
    final query = await _firestore.collection('students').where('email', isEqualTo: email).get();
    if (query.docs.isEmpty) return;
    final studentData = query.docs.first.data();
    final branchId = studentData['branchId'];
    final sectionId = studentData['sectionId'];
    final enrolledYear = studentData['enrolledYear'].toString();

    final snapshot = await _firestore
        .collection('branches')
        .doc(branchId)
        .collection('sections')
        .doc(sectionId)
        .collection('subjects')
        .get();

    setState(() {
      subjects = snapshot.docs.map((doc) => doc.data()).toList();
      selectedSubject = subjects.isNotEmpty ? subjects.first['subjectName'] : null;
      isLoading = false;
    });
  }

  Future<void> pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  void sendNotification() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final email = user.email;
    final query = await _firestore.collection('students').where('email', isEqualTo: email).get();
    if (query.docs.isEmpty) return;
    final studentData = query.docs.first.data();
    final branchId = studentData['branchId'];
    final sectionId = studentData['sectionId'];
    final enrolledYear = studentData['enrolledYear'].toString();

    final collectionPath = 'notification/${enrolledYear}_${branchId}_${sectionId}/history';

    String title = selectedNotice;
    String body = defaultMessageController.text.trim();

    if (selectedNotice == "Custom Notification") {
      title = customTitleController.text.trim();
      body = customMessageController.text.trim();

      if (title.isEmpty || body.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter title and message!")),
        );
        return;
      }
    }

    await _firestore.collection(collectionPath).add({
      'title': title,
      'body': body,
      'type': selectedNotice,
      'screen': 'alerts',
      'timestamp': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Notification Sent Successfully"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = selectedNotice == "Custom Notification";
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Notification"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Notification Type:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  "Class Bunk",
                  "Class Cancellation",
                  "Custom Notification"
                ].map((notice) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        notice,
                        style: TextStyle(
                          color: selectedNotice == notice ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: selectedNotice == notice,
                      selectedColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (bool selected) {
                        setState(() {
                          selectedNotice = notice;
                          customMessageController.clear();
                          customTitleController.clear();
                          defaultMessageController.clear();
                          pickedFile = null;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            if (!isCustom) ...[
              const Text("Select Subject:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedSubject,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: subjects.map((subj) {
                      return DropdownMenuItem<String>(
                        value: subj['subjectName'],
                        child: Text(subj['subjectName'] ?? ""),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSubject = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Notification Message:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: defaultMessageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter message",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],

            if (isCustom) ...[
              const Text("Notification Title:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: customTitleController,
                decoration: InputDecoration(
                  hintText: "Enter Title",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Notification Message:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: customMessageController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Enter Message",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickAttachment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(pickedFile == null ? "Attach File" : pickedFile!.name),
              ),
            ],

            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: sendNotification,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Send Notification", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
