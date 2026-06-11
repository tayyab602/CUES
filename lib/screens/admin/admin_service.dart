import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; //  FIXED: Added missing package import for storage removal

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Check if current user is admin
  Future<bool> isAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] == 'admin';
  }

  // Get all users
  Stream<QuerySnapshot> getAllUsers() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get all items (Marketplace + Lost & Found combined)
  Stream<QuerySnapshot> getAllItems() {
    return _db
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  //  FIXED: Stream points to unified 'items' collection filtered by type discriminator
  Stream<QuerySnapshot> getAllLostFoundItems(String itemType) {
    return _db
        .collection('items')
        .where('type', isEqualTo: itemType)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get all claims
  Stream<QuerySnapshot> getAllClaims() {
    return _db
        .collection('claims')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Delete any item from any collection
  Future<void> deleteDocument(String collection, String docId) async {
    await _db.collection(collection).doc(docId).delete();
  }

  // Ban/unban user (update status flag)
  Future<void> toggleUserBan(String uid, bool isBanned) async {
    await _db.collection('users').doc(uid).update({
      'isBanned': isBanned,
    });
  }

  // Cascading cleanup transaction execution node
  Future<void> executeCascadingUserDeletion(String targetUid) async {
    final WriteBatch batch = _db.batch();

    // 1. Delete all Items posted by this user
    final itemsQuery = await _db.collection('items').where('userId', isEqualTo: targetUid).get();
    for (var doc in itemsQuery.docs) {
      batch.delete(doc.reference);

      final List<dynamic> images = doc.data()['images'] ?? [];
      if (images.isNotEmpty && images[0].toString().isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(images[0]).delete();
        } catch (_) {}
      }
    }

    // 2. Delete all Active Claim Records logged by this user
    final claimsQuery = await _db.collection('claims').where('claimerId', isEqualTo: targetUid).get();
    for (var doc in claimsQuery.docs) {
      batch.delete(doc.reference);
    }

    // 3. Clear Chat Nodes linked to this user's profile
    final chatsQuery = await _db.collection('chats').where('participants', arrayContains: targetUid).get();
    for (var doc in chatsQuery.docs) {
      batch.delete(doc.reference);
    }

    // 4. Remove the User Meta Profile Record
    final userDocRef = _db.collection('users').doc(targetUid);
    batch.delete(userDocRef);

    // Commit all deletions atomically in a single network pass
    await batch.commit();
  }

  //  FIXED: Sync stats calculations strictly with our unified database architecture rules
  Future<Map<String, int>> getStats() async {
    final results = await Future.wait([
      _db.collection('users').get(),
      _db.collection('items').get(),
      _db.collection('items').where('type', isEqualTo: 'lost').get(), // Reads lost dynamically
      _db.collection('items').where('type', isEqualTo: 'found').get(), // Reads found dynamically
      _db.collection('claims').get(),
      _db.collection('chats').get(),
      _db.collection('items').where('status', isEqualTo: 'sold').get(),
      _db.collection('claims').where('status', isEqualTo: 'approved').get(),
    ]);

    return {
      'users': results[0].size,
      'items': results[1].size,
      'lostItems': results[2].size,
      'foundItems': results[3].size,
      'claims': results[4].size,
      'chats': results[5].size,
      'soldItems': results[6].size,
      'approvedClaims': results[7].size,
    };
  }
}