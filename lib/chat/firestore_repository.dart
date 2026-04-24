import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';
import 'repository.dart';

class FirestoreChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<ChatRoom>> fetchChatRooms(String userId) {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<ChatMessage>> fetchMessages(String roomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  @override
  Future<String> createChatRoom(String user1Id, String user2Id, String user1Name, String user2Name) async {
    // Attempt to find an existing room
    final querySnapshot = await _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: user1Id)
        .get();
        
    for (var doc in querySnapshot.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      if (participants.contains(user2Id)) {
        return doc.id; // Room already exists
      }
    }

    // Create a new room
    final docRef = await _firestore.collection('chat_rooms').add({
      'participants': [user1Id, user2Id],
      'lastMessage': 'Chat started',
      'updatedAt': FieldValue.serverTimestamp(),
      'participantNames': {
        user1Id: user1Name,
        user2Id: user2Name,
      },
    });

    return docRef.id;
  }

  @override
  Future<bool> sendMessage(String roomId, String senderId, String text) async {
    final batch = _firestore.batch();
    
    // 1. Add message to messages subcollection
    final msgRef = _firestore.collection('chat_rooms').doc(roomId).collection('messages').doc();
    batch.set(msgRef, {
      'roomId': roomId,
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // 2. Update the parent room's last message
    final roomRef = _firestore.collection('chat_rooms').doc(roomId);
    batch.update(roomRef, {
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    try {
      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> markMessagesAsRead(String roomId, String userId) async {
    try {
      final unreadMsgs = await _firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadMsgs.docs.isEmpty) return true;

      final batch = _firestore.batch();
      for (var doc in unreadMsgs.docs) {
        if (doc.data()['senderId'] != userId) {
          batch.update(doc.reference, {'isRead': true});
        }
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }
}
