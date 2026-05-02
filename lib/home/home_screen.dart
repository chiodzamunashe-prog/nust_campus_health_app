import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'package:nust_campus_health_app/profile/profile_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.pushNamed(context, '/chat_list'),
          ),
          _buildNotificationsButton(context),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildEmergencySection(context),
            const SizedBox(height: 32),
            _buildQuickActions(context),
            const SizedBox(height: 32),
            _buildNewsSection(context),
            const SizedBox(height: 32),
            _buildHealthTip(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsButton(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthService.instance.isLoggedIn,
      builder: (context, loggedIn, _) {
        return FutureBuilder<int>(
          future: loggedIn
              ? AuthService.instance
                    .getNotificationsRepository()
                    .getUnreadCount(AuthService.instance.currentUserId)
              : Future<int>.value(0),
          builder: (context, snapshot) {
            final hasUnread = (snapshot.data ?? 0) > 0;

            return IconButton(
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none),
                  if (hasUnread)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF003366), // NUST Deep Blue
            Color(0xFF004D99),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Good Morning,',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AuthService.instance.currentUserDisplayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFFFB81C),
                  size: 20,
                ), // NUST Gold
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Appointment',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const Text(
                        'Dr. Smith - Today, 2:00 PM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.red.shade100, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emergency,
                color: Colors.red.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus Emergency',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB71C1C),
                    ),
                  ),
                  Text(
                    'Immediate medical help',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/emergency_hub'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('Call Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildActionCard(
                context,
                'Appointments',
                Icons.event_note,
                Colors.blue.shade600,
                onTap: () => Navigator.pushNamed(context, '/my_appointments'),
              ),
              _buildActionCard(
                context,
                'Records',
                Icons.folder_shared,
                Colors.orange.shade600,
                onTap: () => Navigator.pushNamed(context, '/medical_records'),
              ),
              _buildActionCard(
                context,
                'Pharmacy',
                Icons.medication,
                Colors.green.shade600,
                onTap: () =>
                    Navigator.pushNamed(context, '/student_prescriptions'),
              ),
              _buildActionCard(
                context,
                'Counseling',
                Icons.psychology,
                Colors.purple.shade600,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Campus News',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildNewsCard(
                'Free Flu Shots',
                'Visit the clinic this Friday for your annual vaccination.',
                'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&q=80&w=400',
              ),
              _buildNewsCard(
                'Mental Health Week',
                'Join us for daily workshops in the student lounge.',
                'https://images.unsplash.com/photo-1527137342181-19aab11a8ee1?auto=format&fit=crop&q=80&w=400',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(String title, String subtitle, String imageUrl) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF003366), // NUST Blue
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFFB81C).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFFFFB81C),
                  size: 24,
                ), // NUST Gold
                SizedBox(width: 12),
                Text(
                  'Daily Health Tip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Drink at least 8 glasses of water today to stay hydrated and maintain focus during lectures.',
              style: TextStyle(fontSize: 15, height: 1.5).whiteb2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF003366),
            ), // NUST Blue
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'NUST Campus Health',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Student Portal',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<UserRole>(
            valueListenable: AuthService.instance.userRole,
            builder: (context, role, _) {
              if (role != UserRole.admin) return const SizedBox.shrink();
              return ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin Panel'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin');
                },
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AuthService.instance.isLoggedIn,
            builder: (context, loggedIn, _) {
              return ListTile(
                leading: const Icon(Icons.medical_services),
                title: const Text('Psychiatrist Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  if (loggedIn) {
                    Navigator.pushNamed(context, '/psy_dashboard');
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/login',
                      arguments: '/psy_dashboard',
                    );
                  }
                },
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AuthService.instance.isLoggedIn,
            builder: (context, loggedIn, _) {
              return ListTile(
                leading: const Icon(Icons.medical_services_outlined),
                title: const Text('GP Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  if (loggedIn) {
                    Navigator.pushNamed(context, '/gp_dashboard');
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/login',
                      arguments: '/gp_dashboard',
                    );
                  }
                },
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AuthService.instance.isLoggedIn,
            builder: (context, loggedIn, _) {
              return ListTile(
                leading: const Icon(Icons.biotech),
                title: const Text('Lab Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  if (loggedIn) {
                    Navigator.pushNamed(context, '/lab_dashboard');
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/login',
                      arguments: '/lab_dashboard',
                    );
                  }
                },
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AuthService.instance.isLoggedIn,
            builder: (context, loggedIn, _) {
              return ListTile(
                leading: const Icon(Icons.medication),
                title: const Text('Pharmacy Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  if (loggedIn) {
                    Navigator.pushNamed(context, '/pharmacist_dashboard');
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/login',
                      arguments: '/pharmacist_dashboard',
                    );
                  }
                },
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AuthService.instance.isLoggedIn,
            builder: (context, loggedIn, _) {
              return ListTile(
                leading: const Icon(Icons.folder_shared),
                title: const Text('Medical Records'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/medical_records');
                },
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AuthService.instance.isLoggedIn,
            builder: (context, loggedIn, _) {
              return ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications & Reminders'),
                onTap: () {
                  Navigator.pop(context);
                  if (loggedIn) {
                    Navigator.pushNamed(context, '/notifications');
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/login',
                      arguments: '/notifications',
                    );
                  }
                },
              );
            },
          ),
          const Divider(),
          ValueListenableBuilder<bool>(
            valueListenable: AuthService.instance.isLoggedIn,
            builder: (context, loggedIn, _) {
              return ListTile(
                leading: Icon(loggedIn ? Icons.logout : Icons.login),
                title: Text(loggedIn ? 'Logout' : 'Login'),
                onTap: () async {
                  Navigator.pop(context);
                  if (loggedIn) {
                    await AuthService.instance.logout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out')),
                      );
                    }
                  } else {
                    Navigator.pushNamed(context, '/login');
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

extension on TextStyle {
  TextStyle get whiteb2 => copyWith(color: Colors.white.withOpacity(0.85));
}
