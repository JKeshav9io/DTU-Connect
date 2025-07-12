import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late SharedPreferences _prefs;
  bool _isLoading = true;
  bool _isRefreshing = false;

  late String _subscriptionTopic;
  late String _lastFetchKey;
  late String _notificationsKey;
  late String _eventsKey;

  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _initPrefsAndLoad();
  }

  Future<void> _initPrefsAndLoad() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadAndFetch();
  }

  Future<void> _loadAndFetch({bool force = false}) async {
    setState(() => _isLoading = !force);
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final studentQuery = await _firestore
        .collection('students')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    if (studentQuery.docs.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    final data = studentQuery.docs.first.data();
    final year = data['enrolledYear']?.toString() ?? '2024';
    final branchId = data['branchId']?.toString() ?? 'BR';
    final sectionId = data['sectionId']?.toString() ?? 'S1';

    _subscriptionTopic = '${year}_${branchId}_${sectionId}';
    _lastFetchKey = 'lastFetch_$_subscriptionTopic';
    _notificationsKey = 'notifs_$_subscriptionTopic';
    _eventsKey = 'events_$_subscriptionTopic';

    _loadCache();

    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _prefs.getInt(_lastFetchKey) ?? 0;
    if (force || now - last > Duration(hours: 1).inMilliseconds) {
      await Future.wait([_fetchNotifications(), _fetchEvents()]);
      await _prefs.setInt(_lastFetchKey, now);
    }

    setState(() {
      _isLoading = false;
      _isRefreshing = false;
    });
  }

  void _loadCache() {
    final notifsJson = _prefs.getString(_notificationsKey);
    if (notifsJson != null) {
      _notifications = (json.decode(notifsJson) as List).cast<Map<String, dynamic>>();
    }
    final eventsJson = _prefs.getString(_eventsKey);
    if (eventsJson != null) {
      _events = (json.decode(eventsJson) as List).cast<Map<String, dynamic>>();
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final snap = await _firestore
          .collection('notification')
          .doc(_subscriptionTopic)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .get();
      _notifications = snap.docs.map((doc) {
        final m = doc.data();
        final rawTs = m['timestamp'] as Timestamp;
        return {
          'id': doc.id,
          'title': m['title'] ?? 'No Title',
          'body': m['body'] ?? '',
          'timestamp': rawTs.millisecondsSinceEpoch,
          'type': m['type'] ?? 'custom',
          'attachment': m['attachmentUrl'],
        };
      }).toList();
      await _prefs.setString(_notificationsKey, json.encode(_notifications));
    } catch (e) {
      debugPrint('❌ fetchNotifications: $e');
    }
    setState(() {});
  }

  Future<void> _fetchEvents() async {
    try {
      final snap = await _firestore
          .collection('notification')
          .doc('events')
          .collection('history')
          .orderBy('timestamp', descending: true)
          .get();
      _events = snap.docs.map((doc) {
        final m = doc.data();
        final rawTs = m['timestamp'] as Timestamp;
        return {
          'id': doc.id,
          'title': m['title'] ?? 'No Title',
          'body': m['body'] ?? '',
          'timestamp': rawTs.millisecondsSinceEpoch,
          'type': 'event',
          'attachment': m['attachmentUrl'],
        };
      }).toList();
      await _prefs.setString(_eventsKey, json.encode(_events));
    } catch (e) {
      debugPrint('❌ fetchEvents: $e');
    }
    setState(() {});
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await _loadAndFetch(force: true);
  }

  List<String> get _dates {
    final all = [..._notifications, ..._events];
    final days = all
        .map((i) => DateTime.fromMillisecondsSinceEpoch(i['timestamp']))
        .map((d) => '${d.day}-${d.month}-${d.year}')
        .toSet()
        .toList();
    days.sort((a, b) {
      final pa = a.split('-').map(int.parse).toList();
      final pb = b.split('-').map(int.parse).toList();
      return DateTime(pb[2], pb[1], pb[0])
          .compareTo(DateTime(pa[2], pa[1], pa[0]));
    });
    return days;
  }

  List<Map<String, dynamic>> _itemsForDate(String label) {
    final all = [..._notifications, ..._events];
    final items = all.where((i) {
      final d = DateTime.fromMillisecondsSinceEpoch(i['timestamp']);
      return '${d.day}-${d.month}-${d.year}' == label;
    }).toList();
    items.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    return items;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Alerts & Events'),
      actions: [
        IconButton(
          icon: _isRefreshing
              ? const CircularProgressIndicator(strokeWidth: 2)
              : const Icon(Icons.refresh),
          onPressed: _isRefreshing ? null : _onRefresh,
        ),
      ],
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : (_notifications.isEmpty && _events.isEmpty)
        ? _buildEmptyState()
        : RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _dates
            .map((d) => 1 + _itemsForDate(d).length)
            .reduce((a, b) => a + b),
        itemBuilder: (_, idx) {
          int cursor = 0;
          for (var date in _dates) {
            if (idx == cursor) return _buildDateDivider(date);
            cursor++;
            final items = _itemsForDate(date);
            for (var item in items) {
              if (idx == cursor) return _buildCard(item);
              cursor++;
            }
          }
          return const SizedBox.shrink();
        },
      ),
    ),
  );

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.notifications_off,
            size: 60, color: Theme.of(context).disabledColor),
        const SizedBox(height: 16),
        Text('No alerts or events',
            style: Theme.of(context).textTheme.titleMedium),
        TextButton(onPressed: _onRefresh, child: const Text('Refresh')),
      ],
    ),
  );

  Widget _buildDateDivider(String date) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Row(
      children: [
        const Expanded(child: Divider()),
        Text(date,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const Expanded(child: Divider()),
      ],
    ),
  );

  Widget _buildCard(Map<String, dynamic> item) {
    IconData icon;
    switch (item['type']) {
      case 'Class Bunk':
        icon = Icons.notifications_active;
        break;
      case 'Class Cancellation':
        icon = Icons.cancel;
        break;
      case 'University Notification':
        icon = Icons.school;
        break;
      case 'Custom Notification':
        icon = Icons.settings;
        break;
      case 'assignment':
        icon = Icons.assignment;
        break;
      case 'event':
        icon = Icons.event;
        break;
      default:
        icon = Icons.notifications;
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          item['title'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          item['body'],
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showDetailsDialog(item),
      ),
    );
  }

  void _showDetailsDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) {
        final ts = DateTime.fromMillisecondsSinceEpoch(item['timestamp']);
        return AlertDialog(
          title: Text(item['title']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBodyContent(item['body'], item['attachment']),
                const SizedBox(height: 12),
                Text(
                  'At ${ts.day}-${ts.month}-${ts.year} ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK')),
          ],
        );
      },
    );
  }

  Widget _buildBodyContent(String body, String? attachment) {
    final urlRegex = RegExp(r"(https?://[\w\-\./?=&%]+)");
    final parts = body.split(urlRegex);
    final matches = urlRegex.allMatches(body).toList();
    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i]));
      if (i < matches.length) {
        final url = matches[i].group(0)!;
        spans.add(TextSpan(
          text: url,
          style: const TextStyle(
              decoration: TextDecoration.underline, color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not launch $url')),
                );
              }
            },
        ));
      }
    }
    if (attachment != null && attachment.isNotEmpty) {
      spans.add(const TextSpan(text: '\n'));
      spans.add(TextSpan(
        text: 'View Attachment',
        style: const TextStyle(
            decoration: TextDecoration.underline, color: Colors.blue),
        recognizer: TapGestureRecognizer()
          ..onTap = () => openAttachment(attachment),
      ));
    }
    return RichText(
        text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium, children: spans));
  }

  void openAttachment(String url) async {
    debugPrint('Open attachment: $url');
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open attachment')),
      );
    }
  }
}
