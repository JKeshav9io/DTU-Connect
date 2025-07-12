import 'package:flutter/material.dart';
import 'package:dtu_connect_2/schedule.dart';
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
    return MaterialApp(
      title: 'DTU Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
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
        print(studentData);
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
      const AcademicPerformanceScreen(studentId: '24_B05_027'),
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _selectedIndex == 0
          ? AppBar(
        title: Text(
          'Welcome, Keshav Jha!',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CrPanel()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsScreen()));
            },
          ),
        ],
      )
          : null,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.hintColor,
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
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _infoCard(
                  context,
                  title: "Today's Attendance",
                  value: "85%",
                  progress: 0.85,
                  valueColor: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _nextClassCard(context, time: "04:30 PM", subject: "Mathematics II"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("Quick Actions", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 6 : 4,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _quickActionButton(context, Icons.check, "Attendance", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => Attendance(studentData: studentData!)));
              }),
              _quickActionButton(context, Icons.assignment, "Assignment", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignmentScreen()));
              }),
              _quickActionButton(context, Icons.schedule, "Schedule", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen()));
              }),
              _quickActionButton(context, Icons.event, "Events", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EventsScreen()));
              }),
            ],
          ),
          const SizedBox(height: 20),
          Text("Upcoming Assignments", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _assignmentCard(context, title: "Programming Fundamentals", due: "Tomorrow, 11:59 PM"),
          _assignmentCard(context, title: "Discrete Structures", due: "20 March, 11:59 PM"),
          const SizedBox(height: 20),
          Text("Campus Events", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _eventCard(
            context,
            imageUrl: "Assets/even.jpg",
            title: "Tech Innovation Summit",
            date: "March 20, 2:00 PM - B.R. Auditorium",
          ),
        ],
      ),
    );
  }
}

Widget _infoCard(BuildContext context,
    {required String title, required String value, required double progress, required Color valueColor}) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.dividerColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.dividerColor,
                color: valueColor,
              ),
            ),
            const SizedBox(width: 5),
            Text(value, style: theme.textTheme.bodyMedium?.copyWith(color: valueColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ),
  );
}

Widget _nextClassCard(BuildContext context, {required String time, required String subject}) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.dividerColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Next Class", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(time, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(subject, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
      ],
    ),
  );
}

Widget _quickActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
  final theme = Theme.of(context);
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Icon(icon, size: 30, color: theme.iconTheme.color),
        ),
        const SizedBox(height: 5),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    ),
  );
}

Widget _assignmentCard(BuildContext context, {required String title, required String due}) {
  final theme = Theme.of(context);
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text("Due: $due", style: theme.textTheme.bodySmall),
      trailing: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Submit", style: TextStyle(color: Colors.white)),
      ),
    ),
  );
}

Widget _eventCard(BuildContext context, {required String imageUrl, required String title, required String date}) {
  final theme = Theme.of(context);
  return Card(
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
              Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(date, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            ],
          ),
        ),
      ],
    ),
  );
}
