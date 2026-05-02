import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../appointments/booking_screen.dart';

class CounsellingScreen extends StatelessWidget {
  const CounsellingScreen({super.key});

  final String campusCrisisLine = '+263772123456';

  void _launchCaller() async {
    final Uri url = Uri.parse('tel:$campusCrisisLine');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showTopicAdvice(BuildContext context, String topic, String advice) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.purple.shade600),
                const SizedBox(width: 10),
                Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              advice,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Got it, thanks!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> topics = [
      {
        'title': 'Academic Stress',
        'icon': '📚',
        'advice': 'Break your tasks into smaller steps. Remember, your worth is not defined by your grades. Take regular breaks and stay hydrated.'
      },
      {
        'title': 'Anxiety',
        'icon': '😟',
        'advice': 'Practice deep breathing: inhale for 4 counts, hold for 4, exhale for 4. Focus on things you can control in the present moment.'
      },
      {
        'title': 'Relationships',
        'icon': '🤝',
        'advice': 'Open communication is key. Set healthy boundaries and don\'t be afraid to express your needs clearly and kindly.'
      },
      {
        'title': 'Career Anxiety',
        'icon': '💼',
        'advice': 'It\'s okay not to have everything figured out. Focus on building skills and exploring interests one step at a time.'
      },
      {
        'title': 'Grief',
        'icon': '🕊️',
        'advice': 'Be patient with yourself. Grief has no timeline. Reach out to friends or professionals to share your burden.'
      },
      {
        'title': 'Depression',
        'icon': '🌑',
        'advice': 'Small victories count. Getting out of bed or taking a shower is a win. You don\'t have to go through this alone.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counselling Support'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Emergency SOS Card
            GestureDetector(
              onTap: _launchCaller,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange.shade600,
                      child: const Icon(Icons.phone, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need immediate help?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Call the Campus Crisis Line',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, 
                         size: 16, color: Colors.orange.shade600),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 2. Topics Grid
            const Text(
              'What would you like to talk about?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                return InkWell(
                  onTap: () => _showTopicAdvice(
                    context, topic['title']!, topic['advice']!),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple.shade100),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(topic['icon']!, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 8),
                        Text(
                          topic['title']!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.purple.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // 3. The Main Action: Book a Session
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.purple.shade600,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.white, size: 40),
                  const SizedBox(height: 16),
                  const Text(
                    'Ready to talk to someone?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Schedule a private session with a campus counselor.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BookingScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple.shade600,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Schedule a Session',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. Self-Guided Resources
            const Text(
              'Self-Guided Resources',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildResourceCard(
                    'Managing Exam Panic',
                    '5 min read',
                    Icons.article_outlined,
                    Colors.blue.shade600,
                  ),
                  _buildResourceCard(
                    '2-Minute Breathing',
                    'Guided Exercise',
                    Icons.air,
                    Colors.teal.shade600,
                  ),
                  _buildResourceCard(
                    'Campus Wellness Podcast',
                    'Ep. 12: Mindfulness',
                    Icons.podcasts,
                    Colors.pink.shade600,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
