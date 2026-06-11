import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClaimService {
  final _db = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Send claim request
  Future<void> sendClaim({
    required String itemId,
    required String ownerId,
    required String type, // 'lost' or 'marketplace'
    required String description,
  }) async {
    // Check if already claimed
    final existing = await _db
        .collection('claims')
        .where('itemId', isEqualTo: itemId)
        .where('requesterId', isEqualTo: uid)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('You have already sent a claim for this item');
    }

    await _db.collection('claims').add({
      'itemId': itemId,
      'requesterId': uid,
      'ownerId': ownerId,
      'type': type,
      'description': description,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Approve claim
  Future<void> approveClaim({
    required String claimId,
    required String itemId,
    required String type,
  }) async {
    final batch = _db.batch();

    // Update claim status
    batch.update(_db.collection('claims').doc(claimId), {
      'status': 'approved',
      'resolvedAt': DateTime.now().toIso8601String(),
    });

    // Update item status based on type
    String collection;
    String newStatus;

    if (type == 'marketplace') {
      collection = 'items';
      newStatus = 'sold';
    } else if (type == 'found') {
      collection = 'foundItems';
      newStatus = 'claimed';
    } else {
      collection = 'lostItems';
      newStatus = 'claimed';
    }

    batch.update(_db.collection(collection).doc(itemId), {
      'status': newStatus,
    });

    // Reject all other pending claims for same item
    final otherClaims = await _db
        .collection('claims')
        .where('itemId', isEqualTo: itemId)
        .where('status', isEqualTo: 'pending')
        .get();

    for (final doc in otherClaims.docs) {
      if (doc.id != claimId) {
        batch.update(doc.reference, {'status': 'rejected'});
      }
    }

    await batch.commit();
  }

  // Reject claim
  Future<void> rejectClaim(String claimId) async {
    await _db.collection('claims').doc(claimId).update({
      'status': 'rejected',
      'resolvedAt': DateTime.now().toIso8601String(),
    });
  }

  // Get claims received by current user (as owner)
  Stream<QuerySnapshot> getReceivedClaims() {
    return _db
        .collection('claims')
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get claims sent by current user
  Stream<QuerySnapshot> getSentClaims() {
    return _db
        .collection('claims')
        .where('requesterId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}