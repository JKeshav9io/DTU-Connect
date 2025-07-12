import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class EditAssignmentForm extends StatefulWidget {
  final String branchId;
  final String sectionId;
  final String subjectCode;
  final String docId;
  final Map<String, dynamic> initialData;

  const EditAssignmentForm({
    super.key,
    required this.branchId,
    required this.sectionId,
    required this.subjectCode,
    required this.docId,
    required this.initialData,
  });

  @override
  _EditAssignmentFormState createState() => _EditAssignmentFormState();
}

class _EditAssignmentFormState extends State<EditAssignmentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _unitController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;
  PlatformFile? _selectedFile;
  bool _isSubmitted = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Prefill controllers
    _titleController = TextEditingController(text: widget.initialData['title']);
    _unitController = TextEditingController(text: widget.initialData['unit']);
    _descriptionController =
        TextEditingController(text: widget.initialData['description']);
    final raw = widget.initialData['dueDate'];
    if (raw is Timestamp) {
      _selectedDate = raw.toDate();
    } else if (raw is String) {
      _selectedDate = DateTime.tryParse(raw);
    }
    _isSubmitted = widget.initialData['isSubmitted'] ?? false;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;
    setState(() => _isSaving = true);

    final ref = FirebaseFirestore.instance
        .collection('branches')
        .doc(widget.branchId)
        .collection('sections')
        .doc(widget.sectionId)
        .collection('subjects')
        .doc(widget.subjectCode)
        .collection('assignments')
        .doc(widget.docId);

    final updateData = {
      'title': _titleController.text.trim(),
      'unit': _unitController.text.trim(),
      'description': _descriptionController.text.trim(),
      'dueDate': Timestamp.fromDate(_selectedDate!),
      'isSubmitted': _isSubmitted,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (_selectedFile != null) {
      updateData['fileName'] = _selectedFile!.name;
      updateData['fileBytes'] = _selectedFile!.bytes as Object;
    }

    await ref.update(updateData);

    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment updated successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: 'Assignment Title'),
                  validator: (val) => val!.isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 12),
                const Text('Subject Code', style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(widget.subjectCode),
                ),
                const SizedBox(height: 12),
                const Text('Unit', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(hintText: 'e.g., Unit 2'),
                  validator: (val) => val!.isEmpty ? 'Enter unit' : null,
                ),
                const SizedBox(height: 12),
                const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Description'),
                  validator: (val) => val!.isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 12),
                const Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  title: Text(_selectedDate == null
                      ? 'Select date'
                      : DateFormat('dd MMM yyyy').format(_selectedDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
                const SizedBox(height: 12),
                const Text('Attachment', style: TextStyle(fontWeight: FontWeight.bold)),
                OutlinedButton(
                  onPressed: _pickFile,
                  child: Text(_selectedFile == null
                      ? 'Change File'
                      : 'Selected: ${_selectedFile!.name}'),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _isSubmitted,
                  title: const Text('Mark assignment as submitted'),
                  onChanged: (val) => setState(() => _isSubmitted = val!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Changes'),
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
