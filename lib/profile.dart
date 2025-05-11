import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isDarkModeEnabled = false;
  bool isNotificationsEnabled = true;

  // Hardcoded user data
  final Map<String, dynamic> userData = {
    'name': 'Keshav Jha',
    'roll_no': 'MCE1021',
    'imageURL': 'Assets/keshav.jpg',
    'attendance': {'Overall': {'overall_percent': '85%'}},
    'cgpa': '8.7',
    'semester': '5',
    'branch': 'MCE',
    'course': 'B.Tech',
    'year': '3rd Year',
    'phone': '+91 9876543210',
    'email': 'keshav.jha@dtuconnect.com',
  };

  void _logout() {
    // Stub logout: navigate back
    Navigator.pop(context);
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
              child: Image.asset(
                userData['imageURL'],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userData['name'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              userData['roll_no'],
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _infoCard("Semester", userData['semester']),
                const SizedBox(width: 8),
                _infoCard("Attendance", userData['attendance']['Overall']['overall_percent']),
                const SizedBox(width: 8),
                _infoCard("CGPA", userData['cgpa']),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileCard(
              rollNo: userData['roll_no'],
              branch: userData['branch'],
              course: userData['course'],
              year: userData['year'],
              phone: userData['phone'],
              email: userData['email'],
            ),
            const SizedBox(height: 16),
            _Settings(
              isDarkMode: isDarkModeEnabled,
              isNotifications: isNotificationsEnabled,
              onDarkModeChanged: (val) => setState(() => isDarkModeEnabled = val),
              onNotificationsChanged: (val) => setState(() => isNotificationsEnabled = val),
              onLogout: _logout,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for small info cards
  Widget _infoCard(String title, String value) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // Profile details card
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
            const Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  // Row widget for label and value
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Settings section as separate widget
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
            title: const Text("Edit Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined, color: Colors.deepPurple),
            title: const Text("Dark Mode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            trailing: Switch(value: isDarkMode, onChanged: onDarkModeChanged, activeColor: Colors.deepPurple),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications_active, color: Colors.green),
            title: const Text("Notifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            trailing: Switch(value: isNotifications, onChanged: onNotificationsChanged, activeColor: Colors.green),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.redAccent)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
