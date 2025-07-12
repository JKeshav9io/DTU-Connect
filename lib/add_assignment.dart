import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class AssignmentForm extends StatefulWidget {
  const AssignmentForm({super.key});

  @override
  _AssignmentFormState createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<AssignmentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  String? _selectedSubjectCode;

  DateTime? _selectedDate;
  PlatformFile? _selectedFile;

  bool _isSubmitting = false;
  bool _isLoadingSubjects = true;
  List<Map<String, String>> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('branches')
        .doc('MCE')
        .collection('sections')
        .doc('B05')
        .collection('subjects')
        .get();
    _subjects = snapshot.docs.map((doc) {
      return {
        'code': doc['subjectCode'] as String,
        'name': doc['subjectName'] as String,
      };
    }).toList();
    if (_subjects.isNotEmpty) {
      _selectedSubjectCode = _subjects.first['code'];
    }
    setState(() => _isLoadingSubjects = false);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _submitAssignment() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedFile == null ||
        _selectedSubjectCode == null) return;

    setState(() => _isSubmitting = true);

    final assignId = 'assign_${DateTime.now().millisecondsSinceEpoch}';

    await FirebaseFirestore.instance
        .collection('branches')
        .doc('MCE')
        .collection('sections')
        .doc('B05')
        .collection('subjects')
        .doc(_selectedSubjectCode)
        .collection('assignments')
        .doc(assignId)
        .set({
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'unit': _unitController.text.trim(),
      'subjectCode': _selectedSubjectCode,
      'dueDate': Timestamp.fromDate(_selectedDate!),
      'fileName': _selectedFile!.name,
      'fileBytes': _selectedFile!.bytes,
      'isSubmitted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment added successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoadingSubjects
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Title',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Assignment 1',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 12),
                const Text('Subject',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border:
                    Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedSubjectCode,
                      onChanged: (val) => setState(
                              () => _selectedSubjectCode = val),
                      items: _subjects.map((subj) {
                        return DropdownMenuItem<String>(
                          value: subj['code'],
                          child: Text(subj['name']!),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Unit',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Unit 2',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter unit' : null,
                ),
                const SizedBox(height: 12),
                const Text('Description',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText:
                    'Brief description of the assignment',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                  val!.isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 12),
                const Text('Due Date',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(8)),
                  tileColor: Theme.of(context).cardColor,
                  title: Text(
                    _selectedDate == null
                        ? 'Select due date'
                        : 'Due: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}',
                  ),
                  trailing: const Icon(
                      Icons.calendar_today),
                  onTap: () async {
                    final picked =
                    await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null)
                      setState(
                              () => _selectedDate = picked);
                  },
                ),
                const SizedBox(height: 12),
                const Text('Attachment',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Theme.of(context)
                              .primaryColor),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(8)),
                    ),
                    onPressed: _pickFile,
                    child: Text(
                      _selectedFile == null
                          ? 'Select File'
                          : 'Selected: ${_selectedFile!.name}',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(8)),
                    ),
                    onPressed:
                    _isSubmitting ? null : _submitAssignment,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                        color: Colors.white)
                        : const Text('Submit Assignment'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
