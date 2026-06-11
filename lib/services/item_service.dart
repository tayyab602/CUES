import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Deletes an item, its associated image, and archives related chat rooms.
  Future<void> resolveItem(String itemId, String imageUrl, {String collection = 'items'}) async {
    try {
      // 1. Delete the item document from Firestore
      await _db.collection(collection).doc(itemId).delete();

      // 2. Delete the image from Firebase Storage if a URL exists
      if (imageUrl.isNotEmpty) {
        try {
          await _storage.refFromURL(imageUrl).delete();
        } catch (e) {
          // If the file was already deleted or doesn't exist, we skip to avoid crashing
          print("Storage deletion failed or file already removed: $e");
        }
      }

      // 3. Clean up associated chat rooms
      final chatSnapshots = await _db
          .collection('chats')
          .where('itemId', isEqualTo: itemId)
          .get();

      if (chatSnapshots.docs.isNotEmpty) {
        final batch = _db.batch();
        for (var doc in chatSnapshots.docs) {
          // Mark as archived to prevent ghost rooms and keep history if needed
          batch.update(doc.reference, {
            'status': 'archived',
            'isActive': false,
            'resolvedAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Error executing clean-up pipeline: $e');
    }
  }

  /// Bulk version for multiple images if needed in the future
  Future<void> resolveItemWithMultipleImages(String itemId, List<String> imageUrls) async {
    try {
      await _db.collection('items').doc(itemId).delete();

      for (String url in imageUrls) {
        if (url.isNotEmpty) {
          try {
            await _storage.refFromURL(url).delete();
          } catch (_) {}
        }
      }

      final chatSnapshots = await _db.collection('chats').where('itemId', isEqualTo: itemId).get();
      final batch = _db.batch();
      for (var doc in chatSnapshots.docs) {
        batch.delete(doc.reference); // Example of hard deletion for chats
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error executing bulk clean-up: $e');
    }
  }
}
