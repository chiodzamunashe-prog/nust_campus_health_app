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
                Icon(Icons.lightbulb, color: Colors.yellow.shade700),
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
                  backgroundColor: const Color(0xFF1565C0),
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
   void _showResourceDetail(BuildContext context, Map<String, dynamic> resource) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Essential to allow height > 50%
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView( 
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(resource['icon'], color: resource['color'], size: 40),
                      const SizedBox(height: 16),
                      Text(
                        resource['title'],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        resource['subtitle'],
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                      const Divider(height: 32),
                      Text(
                        resource['content'],
                        style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: resource['color'],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
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
        'advice': 'Break your large assignments into smaller, manageable milestones to prevent feeling overwhelmed by the overall workload. Remember that your personal worth is not defined by your grades, and academic setbacks are simply opportunities for growth. Establish a balanced routine that includes dedicated study periods, regular screen-free breaks, and adequate hydration.'
      },
      {
        'title': 'Anxiety',
        'icon': '😟',
        'advice': 'Ground yourself by practicing the 4-4-4 breathing technique: inhale deeply for four counts, hold for four, and exhale slowly for four. Deliberately shift your focus away from future uncertainties and concentrate only on the tangible things you can control in the present moment. If your thoughts begin to race, try physically writing them down to externalize the stress and clear your mind.'
      },
      {
        'title': 'Relationships',
        'icon': '🤝',
        'advice': 'Cultivate open, honest communication by actively listening to others and expressing your own feelings without placing blame. It is crucial to establish and maintain healthy boundaries to protect your emotional well-being and foster mutual respect. Do not hesitate to articulate your personal needs clearly and kindly, as a strong relationship allows space for both individuals to thrive.'
      },
      {
        'title': 'Career Anxiety',
        'icon': '💼',
        'advice': 'Understand that it is perfectly normal not to have your entire career trajectory figured out during your university years. Instead of worrying about the final destination, focus on continuously building adaptable skills and exploring your genuine interests one step at a time. Seek out mentorship and internship opportunities to gain practical experience that will naturally guide your professional journey.'
      },
      {
        'title': 'Grief',
        'icon': '🕊️',
        'advice': 'Allow yourself the grace to process your emotions without judgment, recognizing that grief is a deeply personal journey with no set timeline. It is important to acknowledge your feelings rather than suppressing them, as healing occurs gradually through acceptance. Please do not isolate yourself during this difficult period; actively reach out to trusted friends, family, or campus professionals who can help carry the burden.'
      },
      {
        'title': 'Depression',
        'icon': '🌑',
        'advice': 'When facing depression, recognize that even the smallest daily victories, such as getting out of bed or eating a proper meal, are significant achievements. Practice self-compassion by removing unrealistic expectations and simply taking each day one hour at a time. Most importantly, remember that you do not have to navigate the darkness alone; professional campus counselors are here to provide the support and tools you need to heal.'
      },
    ];
    final List<Map<String, dynamic>> resources = [
      {
        'title': 'Managing Exam Panic',
        'subtitle': '5 min read',
        'icon': Icons.article_outlined,
        'color': Colors.blue.shade600,
        'content': 'Exam panic is a common physiological response. To manage it:\n\n'
                  '1. Preparation: Break your syllabus into small, manageable chunks.\n'
                  '2. The 5-5-5 Rule: If you feel a panic attack coming, stop and find 5 things you can see, 4 you can touch, and 3 you can hear.\n'
                  '3. Positive Visualization: Spend 2 minutes imagining yourself sitting calmly and answering questions correctly.\n'
                  '4. Physical Health: Avoid excessive caffeine; it mimics the physical symptoms of anxiety. Ensure at least 6 hours of sleep before an exam.\n\n'
                  'Remember: One exam does not define your entire future. You have prepared for this, and you are capable.'
      },
      {
        'title': '2-Minute Breathing',
        'subtitle': 'Guided Exercise',
        'icon': Icons.air,
        'color': Colors.teal.shade600,
        'content': 'Follow this Box Breathing technique to reset your nervous system:\n\n'
                  '• Step 1: Inhale through your nose for a count of 4.\n'
                  '• Step 2: Hold your breath for a count of 4.\n'
                  '• Step 3: Exhale slowly through your mouth for a count of 4.\n'
                  '• Step 4: Wait for a count of 4 before your next breath.\n\n'
                  'Repeat this cycle four times. This technique is used by athletes and professionals to regain focus and lower cortisol levels instantly.'
      },
      {
        'title': 'Campus Wellness Podcast',
        'subtitle': 'Ep. 12: Mindfulness',
        'icon': Icons.podcasts,
        'color': Colors.pink.shade600,
        'content': 'In this episode, Dr. Moyo discusses how mindfulness can be integrated into a busy student schedule.\n\n'
                  'Key Takeaways:\n'
                  '• Mindful Eating: Spend 5 minutes eating without your phone.\n'
                  '• Active Listening: Truly hearing others without preparing your response.\n'
                  '• Forgiving Yourself: Understanding that productivity varies day to day.\n\n'
                  'Listen to the full episode on the Campus Intranet or via the "Multimedia" tab in this app.'
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
                  border: Border.all(color: Colors.redAccent),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:Colors.red,
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
                         size: 16, color: Colors.red),
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
                      color: const Color.fromARGB(255, 32, 102, 173),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
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
                            color: Colors.white,
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
                color: const Color(0xFF003366),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF003366).withOpacity(0.3),
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
                      foregroundColor: const Color(0xFF003366),
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: resources.length,
                itemBuilder: (context, index) {
                  return _buildResourceCard(context, resources[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, Map<String, dynamic> resource) {
    return InkWell(
      onTap: () => _showResourceDetail(context, resource), // Trigger the modal
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                color: resource['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(resource['icon'], color: resource['color']),
            ),
            const Spacer(),
            Text(
              resource['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              resource['subtitle'],
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
