import 'package:flutter/material.dart';

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  String selectedClass = "Discrete Mathematics";
  String selectedNotice = "Class Bunk";
  final TextEditingController customMessageController = TextEditingController();
  final TextEditingController customTitleController = TextEditingController();

  final List<String> classes = [
    "Discrete Mathematics",
    "Mathematical Foundations",
    "Algorithms",
    "Data Structures"
  ];

  final List<String> notices = [
    "Class Bunk",
    "Class Cancellation",
    "University Notification",
    "Custom Notification",
  ];

  void sendNotification() {
    String message = selectedNotice;
    String title = selectedTitle;
    if (selectedNotice == "Custom Notification") {
      message = customMessageController.text.trim();
      title = customTitleController.text.trim();
      if (message.isEmpty || title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter title and message!")),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Notification Sent to $selectedClass: $message"),
        backgroundColor: Colors.green,
      ),
    );
  }

  String get selectedTitle => selectedNotice == "Custom Notification"
      ? customTitleController.text.trim()
      : selectedNotice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Send Notification",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Class:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
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
                  items: classes.map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 16)),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Select Notice Type:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: notices.map((notice) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        notice,
                        style: TextStyle(
                          color: selectedNotice == notice ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      selected: selectedNotice == notice,
                      selectedColor: Colors.blue.shade700,
                      backgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (bool selected) {
                        setState(() {
                          selectedNotice = notice;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            if (selectedNotice == "Custom Notification") ...[
              const Text("Notification Title:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: customTitleController,
                decoration: InputDecoration(
                  hintText: "Enter notification title",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
            ],
            const Text("Notification Message:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (selectedNotice == "Custom Notification")
              TextField(
                controller: customMessageController,
                decoration: InputDecoration(
                  hintText: "Enter notification message",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 5,
              )
            else
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(selectedNotice),
              ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: sendNotification,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Send Notification", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
