import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser!.uid;

  // --- 1. UNIQUE IDENTITY ---

  // Search user by shorthand Campus ID
  Future<Map<String, dynamic>?> getUserByCampusId(String campusId) async {
    final snap = await _db.collection('users')
        .where('campusId', isEqualTo: campusId.toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return {'uid': snap.docs.first.id, ...snap.docs.first.data()};
  }

  // --- 2. FRIEND REQUEST FIREWALL ---

  /// Sends a friend request. Returns true if successful, false if a request already exists.
  Future<bool> sendFriendRequest(String targetUid) async {
    if (currentUid == targetUid) return false;

    // Create a unique, deterministic ID by sorting UIDs alphabetically.
    // This ensures A->B and B->A both point to the same document.
    final List<String> ids = [currentUid, targetUid]..sort();
    final String requestId = ids.join('_');

    final docRef = _db.collection('friend_requests').doc(requestId);

    return await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (snapshot.exists) {
        // A request (or friendship) already exists between these two users.
        return false;
      }

      transaction.set(docRef, {
        'fromUid': currentUid,
        'toUid': targetUid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'participants': ids, // Store sorted array for easier querying later
      });

      return true;
    });
  }

  Future<void> acceptFriendRequest(String requestId, String peerUid) async {
    final batch = _db.batch();

    // 1. Update request status
    batch.update(_db.collection('friend_requests').doc(requestId), {'status': 'accepted'});

    // 2. Open a standard direct chat channel
    final chatId = getChatId(currentUid, peerUid);
    batch.set(_db.collection('chats').doc(chatId), {
      'participants': [currentUid, peerUid],
      'type': 'direct',
      'itemId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // --- 3. ANONYMOUS ITEM CHAT BYPASS ---

  Future<String> startItemChat(String posterId, String itemId) async {
    // Unique ID for item-specific chats to allow multiple people to message one poster
    final itemChatId = 'item_${itemId}_$currentUid';

    final doc = await _db.collection('chats').doc(itemChatId).get();
    if (!doc.exists) {
      await _db.collection('chats').doc(itemChatId).set({
        'participants': [currentUid, posterId],
        'type': 'item',
        'itemId': itemId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    return itemChatId;
  }

  // --- 4. IDENTITY INTERCEPTOR (MASKING LOGIC) ---

  Future<String> getMaskedName(String peerUid, String chatType) async {
    // Rule: If it's a direct chat, they must be friends -> Show real name
    if (chatType == 'direct') {
      final userDoc = await _db.collection('users').doc(peerUid).get();
      return userDoc['name'] ?? 'User';
    }

    // Rule: For item chats, check friendship first
    final friendship = await _db.collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .where('fromUid', whereIn: [currentUid, peerUid])
        .get();

    bool areFriends = friendship.docs.any((doc) {
      final data = doc.data();
      return (data['fromUid'] == currentUid && data['toUid'] == peerUid) ||
          (data['fromUid'] == peerUid && data['toUid'] == currentUid);
    });

    if (areFriends) {
      final userDoc = await _db.collection('users').doc(peerUid).get();
      return userDoc['name'];
    } else {
      // Intercept and Mask
      final userDoc = await _db.collection('users').doc(peerUid).get();
      final shorthand = userDoc['campusId'] ?? 'ID-XXXX';
      return "Anonymous ($shorthand)";
    }
  }

  String getChatId(String a, String b) {
    return a.hashCode <= b.hashCode ? '${a}_$b' : '${b}_$a';
  }
}