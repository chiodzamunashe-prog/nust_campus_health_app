import 'package:flutter/material.dart';
import 'models.dart';
import 'repository.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String userId;
  final String userRole; // To determine styling (e.g. NUST Blue for students, Dark Teal for GP)

  const ChatListScreen({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Stream<List<ChatRoom>> _chatRoomsStream;

  @override
  void initState() {
    super.initState();
    _chatRoomsStream = chatRepository.fetchChatRooms(widget.userId);
  }

  Color get _themeColor {
    if (widget.userRole == 'gp') return const Color(0xFF004D40); // Dark Teal
    if (widget.userRole == 'psy') return const Color(0xFF2C3E50); // Dark Blue-Grey
    return const Color(0xFF152A69); // NUST Midnight Navy for students/admin
  }

  String _getOtherParticipantName(ChatRoom room) {
    for (var entry in room.participantNames.entries) {
      if (entry.key != widget.userId) {
        return entry.value;
      }
    }
    return 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _themeColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: _chatRoomsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rooms = snapshot.data ?? [];

          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No active conversations.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final room = rooms[index];
              final otherName = _getOtherParticipantName(room);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: _themeColor.withOpacity(0.1),
                  child: Text(
                    otherName[0].toUpperCase(),
                    style: TextStyle(
                      color: _themeColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  otherName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  room.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(room.updatedAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        roomId: room.id,
                        currentUserId: widget.userId,
                        otherUserName: otherName,
                        themeColor: _themeColor,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0 && now.day == date.day) {
      // Same day, show time
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays < 7) {
      // Within last week, show weekday
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } else {
      // Older, show date
      return '${date.day}/${date.month}';
    }
  }
}
