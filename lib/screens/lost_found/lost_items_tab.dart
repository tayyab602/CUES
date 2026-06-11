import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lost_found_card.dart';

class LostItemsTab extends StatefulWidget {
  const LostItemsTab({super.key});

  @override
  State<LostItemsTab> createState() => _LostItemsTabState();
}

class _LostItemsTabState extends State<LostItemsTab>
    with AutomaticKeepAliveClientMixin {
  late final Stream<QuerySnapshot> _lostItemsStream;

  @override
  void initState() {
    super.initState();
    //  FIXED: Pointing to unified 'items' collection with type selector mapping
    _lostItemsStream = FirebaseFirestore.instance
        .collection('items')
        .where('type', isEqualTo: 'lost')
        .where('status', isEqualTo: 'active')
        .where('expiresAt', isGreaterThan: DateTime.now().toIso8601String())
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<QuerySnapshot>(
      stream: _lostItemsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('No lost items reported',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                Text('Tap Report to report a lost item',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return LostFoundCard(
              data: data,
              id: docs[index].id,
              type: 'lost',
            );
          },
        );
      },
    );
  }
}