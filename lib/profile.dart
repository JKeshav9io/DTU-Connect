import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signin_page.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const ProfilePage({Key? key, required this.studentData}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final Map<String, dynamic> studentInfo;
  late final List<dynamic> attendanceData;
  late final List<dynamic> performanceList;
  late final Map<String, dynamic> latestPerformance;

  bool isDarkModeEnabled = false;
  bool isNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    studentInfo       = widget.studentData;
    attendanceData    = studentInfo['attendance'] as List<dynamic>? ?? [];
    performanceList   = studentInfo['performance'] as List<dynamic>? ?? [];
    latestPerformance = performanceList.isNotEmpty
        ? performanceList.last as Map<String, dynamic>
        : <String, dynamic>{};
  }

  double calculateAttendancePercentage() {
    int conducted = attendanceData.where((d) => d['held'] == 'conducted').length;
    int present   = attendanceData.where((d) => d['status'] == 'present').length;
    return conducted == 0 ? 0.0 : present / conducted * 100;
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Logged out successfully!"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Logout failed!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SigninPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: studentInfo["photoURL"] != null
                  ? Image.asset(
                studentInfo["photoURL"],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              studentInfo["name"] ?? 'NA',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              studentInfo["rollNo"] ?? 'NA',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard("Semester", studentInfo["semester"]?.toString() ?? 'NA'),
                _infoCard("Attendance", "${calculateAttendancePercentage().toStringAsFixed(2)}%"),
                _infoCard("CGPA", latestPerformance["cgpa"]?.toString() ?? 'NA'),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileCard(
              rollNo:  studentInfo["rollNo"]    ?? 'NA',
              branch:  studentInfo["branchName"] ?? 'NA',
              course:  studentInfo["course"]     ?? 'NA',
              year:    studentInfo["year"]?.toString() ?? 'NA',
              phone:   studentInfo["contact"]    ?? 'NA',
              email:   studentInfo["email"]      ?? 'NA',
            ),
            const SizedBox(height: 16),
            _Settings(
              isDarkMode:       isDarkModeEnabled,
              isNotifications:  isNotificationsEnabled,
              onDarkModeChanged:      (val) => setState(() => isDarkModeEnabled = val),
              onNotificationsChanged: (val) => setState(() => isNotificationsEnabled = val),
              onLogout: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700])),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String rollNo,
    required String branch,
    required String course,
    required String year,
    required String phone,
    required String email,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Personal Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInfoRow("Roll No:", rollNo),
            _buildInfoRow("Branch:", branch),
            _buildInfoRow("Course:", course),
            _buildInfoRow("Year:", year),
            _buildInfoRow("Phone:", phone),
            _buildInfoRow("Email:", email),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700])),
          Text(value,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _Settings extends StatelessWidget {
  final bool isDarkMode;
  final bool isNotifications;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onLogout;

  const _Settings({
    required this.isDarkMode,
    required this.isNotifications,
    required this.onDarkModeChanged,
    required this.onNotificationsChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
            title: const Text("Edit Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading:
            const Icon(Icons.dark_mode_outlined, color: Colors.deepPurple),
            title: const Text("Dark Mode",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            trailing: Switch(
                value: isDarkMode,
                onChanged: onDarkModeChanged,
                activeColor: Colors.deepPurple),
          ),
          const Divider(),
          ListTile(
            leading:
            const Icon(Icons.notifications_active, color: Colors.green),
            title: const Text("Notifications",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            trailing: Switch(
                value: isNotifications,
                onChanged: onNotificationsChanged,
                activeColor: Colors.green),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
