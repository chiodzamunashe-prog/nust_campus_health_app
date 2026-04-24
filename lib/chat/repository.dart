import 'models.dart';

abstract class ChatRepository {
  /// Fetch all active chat rooms for a specific user
  Stream<List<ChatRoom>> fetchChatRooms(String userId);

  /// Fetch all messages within a specific chat room
  Stream<List<ChatMessage>> fetchMessages(String roomId);

  /// Create a new chat room between two users
  Future<String> createChatRoom(String user1Id, String user2Id, String user1Name, String user2Name);

  /// Send a message to a chat room
  Future<bool> sendMessage(String roomId, String senderId, String text);

  /// Mark all messages in a room as read for a user
  Future<bool> markMessagesAsRead(String roomId, String userId);
}

// Global instance to be initialized in main.dart
late ChatRepository chatRepository;
