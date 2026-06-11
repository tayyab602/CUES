import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lost_items_tab.dart';
import 'lost_found_card.dart';

class FoundItemsTab extends StatefulWidget {
  const FoundItemsTab({super.key});

  @override
  State<FoundItemsTab> createState() => _FoundItemsTabState();
}

class _FoundItemsTabState extends State<FoundItemsTab>
    with AutomaticKeepAliveClientMixin {
  late final Stream<QuerySnapshot> _foundItemsStream;

  @override
  void initState() {
    super.initState();
    //  FIXED: Pointing to unified 'items' collection with type selector mapping
    _foundItemsStream = FirebaseFirestore.instance
        .collection('items')
        .where('type', isEqualTo: 'found')
        .where('status', isEqualTo: 'unclaimed')
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
      stream: _foundItemsStream,
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
                Icon(Icons.find_in_page, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('No found items reported',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                Text('Tap Report to report a found item',
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
              type: 'found',
            );
          },
        );
      },
    );
  }
}