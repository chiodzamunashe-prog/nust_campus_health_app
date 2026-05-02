import 'dart:async';
import 'package:uuid/uuid.dart';
import 'models.dart';
import 'repository.dart';

class MockChatRepository implements ChatRepository {
  final _uuid = const Uuid();
  
  // In-memory data store
  final List<ChatRoom> _rooms = [];
  final List<ChatMessage> _messages = [];
  
  // Stream controllers
  final _roomsController = StreamController<List<ChatRoom>>.broadcast();
  final _messagesController = StreamController<List<ChatMessage>>.broadcast();

  MockChatRepository() {
    // Seed with some mock data for development
    final room1Id = 'room_1';
    _rooms.add(ChatRoom(
      id: room1Id,
      participants: ['student1@nust.ac.zw', 'gp'],
      lastMessage: 'Hello Doctor, I have a question about my prescription.',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      participantNames: {
        'student1@nust.ac.zw': 'Zamazane Chiodza',
        'gp': 'Dr. Smith (GP)'
      },
    ));

    _messages.add(ChatMessage(
      id: 'msg_1',
      roomId: room1Id,
      senderId: 'student1@nust.ac.zw',
      text: 'Hello Doctor, I have a question about my prescription.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: true,
    ));
    
    // Seed a second room with psychiatrist
    final room2Id = 'room_2';
    _rooms.add(ChatRoom(
      id: room2Id,
      participants: ['student1@nust.ac.zw', 'psy'],
      lastMessage: 'Your appointment is confirmed for tomorrow.',
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      participantNames: {
        'student1@nust.ac.zw': 'Zamazane Chiodza',
        'psy': 'Dr. Moyo (Psychiatrist)'
      },
    ));

    _messages.add(ChatMessage(
      id: 'msg_2',
      roomId: room2Id,
      senderId: 'psy',
      text: 'Your appointment is confirmed for tomorrow.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ));
  }

  void _broadcastRooms() {
    _roomsController.add(List.from(_rooms));
  }

  void _broadcastMessages() {
    _messagesController.add(List.from(_messages));
  }

  @override
  Stream<List<ChatRoom>> fetchChatRooms(String userId) async* {
    // Yield the initial current state
    yield _rooms.where((r) => r.participants.contains(userId)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
    // Yield all subsequent updates
    yield* _roomsController.stream.map(
      (rooms) => rooms.where((r) => r.participants.contains(userId)).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt))
    );
  }

  @override
  Stream<List<ChatMessage>> fetchMessages(String roomId) async* {
    // Yield the initial current state
    yield _messages.where((m) => m.roomId == roomId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
    // Yield all subsequent updates
    yield* _messagesController.stream.map(
      (msgs) => msgs.where((m) => m.roomId == roomId).toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp)) // Chronological order
    );
  }

  @override
  Future<String> createChatRoom(String user1Id, String user2Id, String user1Name, String user2Name) async {
    // Check if room already exists
    try {
      final existingRoom = _rooms.firstWhere(
        (r) => r.participants.contains(user1Id) && r.participants.contains(user2Id)
      );
      return existingRoom.id;
    } catch (_) {
      // Room doesn't exist, create it
      final newRoomId = _uuid.v4();
      final newRoom = ChatRoom(
        id: newRoomId,
        participants: [user1Id, user2Id],
        lastMessage: 'Chat started',
        updatedAt: DateTime.now(),
        participantNames: {
          user1Id: user1Name,
          user2Id: user2Name,
        },
      );
      _rooms.add(newRoom);
      _broadcastRooms();
      return newRoomId;
    }
  }

  @override
  Future<bool> sendMessage(String roomId, String senderId, String text) async {
    final newMsg = ChatMessage(
      id: _uuid.v4(),
      roomId: roomId,
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
    );
    _messages.add(newMsg);
    
    // Update the room's last message and updatedAt
    final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex != -1) {
      final oldRoom = _rooms[roomIndex];
      _rooms[roomIndex] = ChatRoom(
        id: oldRoom.id,
        participants: oldRoom.participants,
        lastMessage: text,
        updatedAt: newMsg.timestamp,
        participantNames: oldRoom.participantNames,
      );
    }
    
    _broadcastMessages();
    _broadcastRooms();
    return true;
  }

  @override
  Future<bool> markMessagesAsRead(String roomId, String userId) async {
    bool updated = false;
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].roomId == roomId && _messages[i].senderId != userId && !_messages[i].isRead) {
        _messages[i] = ChatMessage(
          id: _messages[i].id,
          roomId: _messages[i].roomId,
          senderId: _messages[i].senderId,
          text: _messages[i].text,
          timestamp: _messages[i].timestamp,
          isRead: true,
        );
        updated = true;
      }
    }
    if (updated) {
      _broadcastMessages();
    }
    return true;
  }
}

void initMockChatRepository() {
  chatRepository = MockChatRepository();
}
