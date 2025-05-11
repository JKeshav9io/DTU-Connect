import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class UpdateMarksPage extends StatefulWidget {
  const UpdateMarksPage({super.key});

  @override
  State<UpdateMarksPage> createState() => _UpdateMarksPageState();
}

class _UpdateMarksPageState extends State<UpdateMarksPage> {
  String selectedSubject = "Mathematics II";
  String selectedExamType = "MTE";

  final List<String> subjects = ["Mathematics II", "Data Structures", "Operating Systems"];
  final List<String> examTypes = ["MTE", "ETE", "Class Test", "CWS"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update Marks",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B0000),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _subjectDropdown(),
            const SizedBox(height: 10),
            _examTypeChips(),
            const SizedBox(height: 20),
            _infoCards(),
            const SizedBox(height: 20),
            _performanceChart(),
            const SizedBox(height: 20),
            _marksCard("Keshav Jha", "24/B05/027"),
            const SizedBox(height: 10),
            _marksCard("Rahul Kumar", "24/B05/028"),
            const SizedBox(height: 10),
            _marksCard("Rajesh Kumar", "24/B05/029"),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _subjectDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSubject,
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              selectedSubject = newValue!;
            });
          },
          items: subjects.map((subject) {
            return DropdownMenuItem<String>(
              value: subject,
              child: Text(subject, style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _examTypeChips() {
    return Wrap(
      spacing: 8,
      children: examTypes.map((examType) {
        return ChoiceChip(
          label: Text(examType),
          selected: selectedExamType == examType,
          onSelected: (selected) {
            setState(() {
              selectedExamType = examType;
            });
          },
          selectedColor: const Color(0xFFB22222),
          backgroundColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _infoCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _infoCard("Total Students", "50"),
        _infoCard("Average Marks", "75"),
        _infoCard("Topper", "95"),
      ],
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _marksCard(String name, String rollNo) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(rollNo, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            SizedBox(
              width: 100,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Marks",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _performanceChart() {
    final grades = ["A", "B", "C", "D", "E"];
    final marks = [10, 20, 30, 40, 50];
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(grades.length, (i) => BarChartGroupData(
            x: i,
            barRods: [BarChartRodData(toY: marks[i].toDouble(), width: 16)],
          )),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                return Text(grades[value.toInt()], style: const TextStyle(fontSize: 12));
              }),
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
