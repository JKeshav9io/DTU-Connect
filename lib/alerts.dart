import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final List<Map<String, dynamic>> _alerts = [
    {
      'date': '15 March 2025',
      'icon': Icons.notifications,
      'iconColor': Colors.blueGrey,
      'title': 'University Notification',
      'subtitle': 'Important circulars and updates',
    },
    {
      'date': '15 March 2025',
      'icon': Icons.warning_amber_rounded,
      'iconColor': Colors.orange,
      'title': 'Class Bunk Alert',
      'subtitle': 'CR: Class bunk confirmed for AP101',
    },
    {
      'date': '12 March 2025',
      'icon': Icons.cancel,
      'iconColor': Colors.red,
      'title': 'Class Cancellation',
      'subtitle': 'Prof. Sharma: EC101 class at 10 AM is canceled',
    },
  ];

  void _showAlertDialog(String title, String subtitle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(subtitle),
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
      appBar: AppBar(
        title: const Text(
          "Notifications & Class Alerts",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: _alerts.length +  _uniqueDates().length,
        itemBuilder: (context, index) {
          final dates = _uniqueDates();
          int counter = 0;
          for (var d in dates) {
            // date divider
            if (index == counter) {
              return _buildLabeledDivider(d);
            }
            counter++;
            // alerts for this date
            for (var alert in _alerts.where((a) => a['date'] == d)) {
              if (index == counter) {
                return _buildNotificationCard(
                  icon: alert['icon'],
                  iconColor: alert['iconColor'],
                  title: alert['title'],
                  subtitle: alert['subtitle'],
                  onTap: () => _showAlertDialog(alert['title'], alert['subtitle']),
                );
              }
              counter++;
            }
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  List<String> _uniqueDates() {
    return _alerts.map((a) => a['date'] as String).toSet().toList();
  }

  Widget _buildLabeledDivider(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey, thickness: 1.2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey, thickness: 1.2)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
