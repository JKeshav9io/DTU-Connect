import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded event data
    final mvpEvents = [
      {
        'name': 'Tech Innovation Summit',
        'date': 'March 20, 2:00 PM',
        'location': 'B.R. Auditorium',
        'imagePath': 'Assets/Seminar.jpeg',
      },
      {
        'name': 'AI Workshop',
        'date': 'April 5, 10:00 AM',
        'location': 'Lab 302',
        'imagePath': 'Assets/ai.png',
      },
    ];
    final fullEvents = [
      {
        'name': 'Cybersecurity Seminar',
        'description': 'Stay safe in the digital world.',
        'date': 'April 12, 11:00 AM',
        'imagePath': 'Assets/seminar.png',
      },
      {
        'name': 'Startup Pitch Day',
        'description': 'Present your startup ideas.',
        'date': 'May 1, 3:00 PM',
        'imagePath': 'Assets/startup.png',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Events",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Event
            if (mvpEvents.isNotEmpty) _buildEventBanner(mvpEvents.first),
            const SizedBox(height: 12),
            // Featured Events
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Featured Events",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 6),
            ...fullEvents.map((event) => _buildEventCard(
              imagePath: event['imagePath']!,
              title: event['name']!,
              description: event['description']!,
              date: event['date']!,
            )),
            const SizedBox(height: 20),
            // More MVP Events
            if (mvpEvents.length > 1) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "More MVP Events",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ...mvpEvents.sublist(1).map((event) => _buildEventCard(
                imagePath: event['imagePath']!,
                title: event['name']!,
                description: "\${event['date']} | \${event['location']}",
                date: event['date']!,
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventBanner(Map<String, String> event) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              event['imagePath']!,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['name']!,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: Colors.black45,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "\${event['date']} | \${event['location']}",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: Colors.black45,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Register Now"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard({
    required String imagePath,
    required String title,
    required String description,
    required String date,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePath,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  date,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
