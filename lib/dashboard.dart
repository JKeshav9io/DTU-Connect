import 'package:flutter/material.dart';
import 'package:dtu_connect_2/fecthing_data.dart';
import 'package:dtu_connect_2/alerts.dart';
import 'package:dtu_connect_2/assignment.dart';
import 'package:dtu_connect_2/attendance.dart';
import 'package:dtu_connect_2/events_screen.dart';
import 'package:dtu_connect_2/profile.dart';
import 'package:dtu_connect_2/academic_performance.dart';
import 'cr_panel.dart';

Map<String, dynamic>? studentData;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic>? studentData;
  int _selectedIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStudentData();
  }

  Future<void> loadStudentData() async {
    final repo = StudentRepository();
    final data = await repo.fetchStudentData();
    if (data != null) {
      setState(() {
        studentData = data;
        isLoading = false;
      });
    }
  }

  List<Widget> get _screens {
    if (studentData == null) {
      return [
        const Center(child: CircularProgressIndicator()),
      ];
    }
    return [
      const HomeScreen(),
      const AcademicPerformanceScreen(),
      const EventsScreen(),
      const AlertsScreen(),
      ProfilePage(studentData: studentData!),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _selectedIndex == 0
          ? AppBar(
        title: const Text(
          'Welcome, Keshav Jha!',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(studentData: studentData!)),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CrPanel()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertsScreen()),
              );
            },
          ),
        ],
      )
          : null,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Academics'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _infoCard(
                  title: "Today's Attendance",
                  value: "85%",
                  progress: 0.85,
                  valueColor: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _nextClassCard(
                  time: "04:30 PM",
                  subject: "Mathematics II",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Quick Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _quickActionButton(Icons.check, "Attendance", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Attendance()));
              }),
              _quickActionButton(Icons.assignment, "Assignment", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AssignmentScreen()));
              }),
              _quickActionButton(Icons.schedule, "Schedule", () {}),
              _quickActionButton(Icons.event, "Events", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EventsScreen()));
              }),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Upcoming Assignments", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _assignmentCard(title: "Programming Fundamentals", due: "Tomorrow, 11:59 PM"),
          _assignmentCard(title: "Discrete Structures", due: "20 March, 11:59 PM"),
          const SizedBox(height: 20),
          const Text("Campus Events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _eventCard(
            imageUrl: "Assets/even.jpg",
            title: "Tech Innovation Summit",
            date: "March 20, 2:00 PM - B.R. Auditorium",
          ),
        ],
      ),
    );
  }
}

Widget _infoCard({required String title, required String value, required double progress, required Color valueColor}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                color: valueColor,
              ),
            ),
            const SizedBox(width: 5),
            Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ),
  );
}

Widget _nextClassCard({required String time, required String subject}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Next Class", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(subject, style: const TextStyle(color: Colors.grey)),
      ],
    ),
  );
}

Widget _quickActionButton(IconData icon, String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 45, color: Colors.black),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 15)),
      ],
    ),
  );
}

Widget _assignmentCard({required String title, required String due}) {
  return Card(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Due: $due"),
      trailing: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Submit", style: TextStyle(color: Colors.white)),
      ),
    ),
  );
}

Widget _eventCard({required String imageUrl, required String title, required String date}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.asset(imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 5),
              Text(date, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    ),
  );
}