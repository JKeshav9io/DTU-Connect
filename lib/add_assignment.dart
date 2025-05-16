import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AssignmentForm extends StatefulWidget {
  const AssignmentForm({super.key});

  @override
  _AssignmentFormState createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<AssignmentForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  DateTime? _selectedDate;
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  void _submitAssignment() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Assignment Submitted!'),
        content: Text(
          'Title: ${_titleController.text}\n'
              'Subject: ${_subjectController.text}\n'
              'Unit: ${_unitController.text}\n'
              'Due Date: ${_selectedDate?.toLocal().toString().split(' ')[0] ?? 'None'}\n'
              'File: ${_selectedFile?.name ?? 'No file selected'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown[700]!, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown, width: 1.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown[700]!, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown, width: 1.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _unitController,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown[700]!, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown, width: 1.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown[700]!, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown, width: 1.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _selectedDate == null
                      ? 'Select Due Date'
                      : 'Due Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: _pickFile,
                  child: Text(
                    _selectedFile == null
                        ? 'Select File'
                        : 'Selected: ${_selectedFile!.name}',
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: _submitAssignment,
                  child: Text('Submit Assignment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
