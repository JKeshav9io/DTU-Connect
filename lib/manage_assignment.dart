import 'package:dtu_connect_2/add_assignment.dart';
import 'package:flutter/material.dart';

class ManageAssignment extends StatefulWidget {
  const ManageAssignment({super.key});

  @override
  State<ManageAssignment> createState() => _ManageAssignmentState();
}

class _ManageAssignmentState extends State<ManageAssignment> {
  String selectedClass = "Discrete Mathematics";
  String selectedAssignment = "All";

  final List<String> classes = [
    "Discrete Mathematics",
    "Mathematical Foundations",
    "Algorithms",
    "Data Structures"
  ];

  final List<String> assignments = [
    "All",
    "Pending",
    "Submitted",
    "Overdue"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Assignments",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AssignmentForm(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Class:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  value: selectedClass,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedClass = newValue!;
                    });
                  },
                  items: classes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Filter Assignments:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: assignments.map((assignment) {
                return ChoiceChip(
                  label: Text(
                    assignment,
                    style: TextStyle(
                      color: selectedAssignment == assignment ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: selectedAssignment == assignment,
                  selectedColor: Colors.blue.shade700,
                  backgroundColor: Colors.grey.shade300,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedAssignment = assignment;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return const AssignCard();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssignCard extends StatelessWidget {
  const AssignCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Assignment 1",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Overdue",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Subject: Discrete Mathematics - Unit 2",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(
                      "Due: 12th October 2021",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.person, size: 14, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(
                      "10/30 Submitted",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Stub Add Assignment Page

class AddAssignmentPage extends StatelessWidget {
  const AddAssignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Assignment")),
      body: const Center(child: Text("Add Assignment UI Here")),
    );
  }
}
