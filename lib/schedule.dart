// This is a responsive version of TimetableScreen using the theme from your MyApp class
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final String branchId = 'MCE';
  final String sectionId = 'B05';

  Map<String, List<Map<String, dynamic>>> timetable = {};
  String selectedDay = 'Monday';
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    setTodayAsDefault();
    loadTimetable();
  }

  void setTodayAsDefault() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    selectedDay = (now.weekday >= 1 && now.weekday <= 5)
        ? weekdays[now.weekday - 1]
        : 'Monday';
  }

  Future<void> loadTimetable() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('timetable_cache');

      if (cachedData != null) {
        final decoded = jsonDecode(cachedData);
        timetable = Map<String, List<Map<String, dynamic>>>.from(
          decoded.map(
                (key, value) => MapEntry(
              key.toString(),
              List<Map<String, dynamic>>.from(value),
            ),
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('branches')
          .doc(branchId)
          .collection('sections')
          .doc(sectionId)
          .collection('timetable')
          .get();

      final Map<String, List<Map<String, dynamic>>> parsed = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['schedule'] is List) {
          parsed[doc.id] = List<Map<String, dynamic>>.from(data['schedule']);
        }
      }

      timetable = parsed;
      await prefs.setString('timetable_cache', jsonEncode(parsed));
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Widget dayChip(String day) {
    final isSelected = selectedDay == day;
    return ChoiceChip(
      label: Text(day, style: Theme.of(context).textTheme.labelLarge),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
      ),
      onSelected: (_) => setState(() => selectedDay = day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardPadding = screenWidth < 400 ? 12.0 : 16.0;

    final todaySchedule = timetable[selectedDay];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Timetable'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                  .map((day) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: dayChip(day),
              ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                ? const Center(child: Text("Something went wrong."))
                : todaySchedule == null
                ? const Center(child: Text("No timetable available."))
                : todaySchedule.isEmpty
                ? const Center(child: Text("No classes today."))
                : ListView.builder(
              itemCount: todaySchedule.length,
              itemBuilder: (context, index) {
                final item = todaySchedule[index];
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: cardPadding, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.menu_book_rounded),
                                  const SizedBox(width: 8),
                                  Text(
                                    item['subject'] ?? 'Unknown Subject',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Syllabus'),
                                    content: const Text('Syllabus view coming soon...'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      )
                                    ],
                                  ),
                                ),
                                icon: const Icon(Icons.book_outlined, size: 18),
                                label: const Text("Syllabus", style: TextStyle(fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.code, size: 18),
                              const SizedBox(width: 8),
                              Text("Code: ${item['subjectCode'] ?? '-'}"),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 18),
                              const SizedBox(width: 8),
                              Text("Teacher: ${item['teacher'] ?? 'TBA'}"),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.room, size: 18),
                              const SizedBox(width: 8),
                              Text("Room: ${item['room'] ?? '-'}"),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 18),
                              const SizedBox(width: 8),
                              Text("Time: ${item['startTime']} - ${item['endTime']}")
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
