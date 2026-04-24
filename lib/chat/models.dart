import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime updatedAt;
  final Map<String, dynamic> participantNames; // Quick lookup for UI

  ChatRoom({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.updatedAt,
    required this.participantNames,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      participantNames: data['participantNames'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'participantNames': participantNames,
    };
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      roomId: data['roomId'] ?? '',
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}
