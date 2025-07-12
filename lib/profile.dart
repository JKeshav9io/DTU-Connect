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

  @override
  void initState() {
    super.initState();
    studentInfo = widget.studentData;
    attendanceData = studentInfo['attendance'] as List<dynamic>? ?? [];
    performanceList = studentInfo['performance'] as List<dynamic>? ?? [];
    latestPerformance = performanceList.isNotEmpty
        ? performanceList.last as Map<String, dynamic>
        : <String, dynamic>{};
  }

  double calculateAttendancePercentage() {
    int conducted = attendanceData
        .where((d) => d['held'] == 'conducted')
        .length;
    int present = attendanceData
        .where((d) => d['status'] == 'present')
        .length;
    return conducted == 0 ? 0.0 : present / conducted * 100;
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SigninPage()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged out successfully!"),
          backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "My Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight
            .bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileImage(),
            const SizedBox(height: 8),
            Text(
              studentInfo["name"] ?? 'NA',
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              studentInfo["rollNo"] ?? 'NA',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _infoCard(
                    "Semester", studentInfo["semester"]?.toString() ?? 'NA',
                    theme),
                _infoCard("Attendance",
                    "${calculateAttendancePercentage().toStringAsFixed(2)}%",
                    theme),
                _infoCard("CGPA", latestPerformance["cgpa"]?.toString() ?? 'NA',
                    theme),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileDetailsCard(theme),
            const SizedBox(height: 16),
            _LogoutButton(onLogout: _logout),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final photoURL = studentInfo["photoURL"];
    if (photoURL != null && photoURL
        .toString()
        .isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoURL,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _fallbackProfileIcon();
          },
        ),
      );
    }
    return _fallbackProfileIcon();
  }

  Widget _fallbackProfileIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: Colors.grey[300]),
      child: const Icon(Icons.person, size: 50, color: Colors.white),
    );
  }

  Widget _infoCard(String title, String value, ThemeData theme) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600, color: theme.hintColor)),
              const SizedBox(height: 4),
              Text(value,
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetailsCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Personal Information",
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInfoRow("Roll No:", studentInfo["rollNo"] ?? 'NA', theme),
            _buildInfoRow("Branch:", studentInfo["branchName"] ?? 'NA', theme),
            _buildInfoRow("Course:", studentInfo["course"] ?? 'NA', theme),
            _buildInfoRow(
                "Year:", studentInfo["year"]?.toString() ?? 'NA', theme),
            _buildInfoRow("Phone:", studentInfo["contact"] ?? 'NA', theme),
            _buildInfoRow("Email:", studentInfo["email"] ?? 'NA', theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.hintColor,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

  class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.redAccent),
        title: Text("Logout",
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600, color: Colors.redAccent)),
        onTap: onLogout,
      ),
    );
  }
}
