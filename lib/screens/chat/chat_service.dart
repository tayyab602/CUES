import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Create or get existing chat
  Future<String> getOrCreateChat(String otherUserId) async {
    final snapshot = await _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .get();

    for (final doc in snapshot.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(otherUserId)) {
        return doc.id; // chat already exists
      }
    }

    // Create new chat
    final newChat = await _db.collection('chats').add({
      'participants': [uid, otherUserId],
      'lastMessage': '',
      'updatedAt': DateTime.now().toIso8601String(),
    });

    return newChat.id;
  }
}