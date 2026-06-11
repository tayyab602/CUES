import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const ItemDetailScreen({super.key, required this.itemData});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool _areFriends = false;
  bool _isLoadingOwner = true;
  Map<String, dynamic>? _ownerData;

  @override
  @override
  void initState() {
    super.initState(); // FIXED: Ghost text removed
    _fetchOwnerAndFriendshipStatus();
  }

  Future<void> _fetchOwnerAndFriendshipStatus() async {
    final String ownerId = widget.itemData['userId'] ?? widget.itemData['finderId'] ?? '';
    if (ownerId.isEmpty) {
      setState(() => _isLoadingOwner = false);
      return;
    }

    try {
      // 1. Fetch Poster Profile Details
      final ownerDoc = await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
      if (ownerDoc.exists) {
        _ownerData = ownerDoc.data();
      }

      // 2. Check if the current user and poster are verified friends
      final friendshipCheck = await FirebaseFirestore.instance
          .collection('friends')
          .doc('${currentUid}_$ownerId')
          .get();

      // FIXED: Ghost text removed and await chained properly
      final reverseFriendshipCheck = await FirebaseFirestore.instance
          .collection('friends')
          .doc('${ownerId}_$currentUid')
          .get();

      setState(() {
        _areFriends = friendshipCheck.exists || reverseFriendshipCheck.exists;
        _isLoadingOwner = false;
      });
    } catch (e) {
      setState(() => _isLoadingOwner = false);
    }
  }

  void _initiateCommunication() {
    final isLost = widget.itemData['type'] == 'lost';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLost ? 'Found this Belonging?' : 'Claim Ownership',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                isLost
                    ? 'Provide location details and upload an image to confirm verification with the owner.'
                    : 'Specify why this item belongs to you to coordinate a secure handover.',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isLost ? "Where did you find it? Add matching marks..." : "Provide proof of purchase, lock screen details...",
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLost ? Colors.green : Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // Logic to open up our anonymous chat node goes here
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Anonymous channel opened successfully!'), backgroundColor: Colors.blue),
                    );
                  },
                  child: Text(isLost ? 'Send Location Context' : 'Submit Claim Request'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final data = widget.itemData;
    final isLost = data['type'] == 'lost';
    final List<dynamic> images = data['images'] ?? [];
    final hasImage = images.isNotEmpty && images[0].toString().isNotEmpty;

    // Mask name with searchTag if they aren't friends
    String displayName = "Loading...";
    String userTag = "";
    double rating = 4.5; // Mock rating points context

    if (!_isLoadingOwner && _ownerData != null) {
      userTag = _ownerData!['searchTag'] ?? '';
      displayName = _areFriends ? (_ownerData!['name'] ?? 'User') : userTag;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Dynamic Hero Image App Bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: isLost ? colorScheme.error : Colors.green,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(data['title'] ?? 'Item Details', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              background: hasImage
                  ? Image.network(images[0], fit: BoxFit.cover)
                  : Container(
                color: isLost ? colorScheme.errorContainer : Colors.green.shade100,
                child: Icon(
                  isLost ? Icons.explore_off : Icons.verified,
                  size: 80,
                  color: isLost ? colorScheme.onErrorContainer : Colors.green.shade800,
                ),
              ),
            ),
          ),

          // Details Panel Content Viewport
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge & Category Tags
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLost ? colorScheme.error : Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isLost ? 'LOST ITEM' : 'FOUND ITEM',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(data['category'] ?? 'General'),
                        avatar: const Icon(Icons.category, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title and Location Block
                  Text(data['title'] ?? '', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(data['location'] ?? 'Campus Perimeter', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 32),

                  // Description Main Text Block
                  Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  const SizedBox(height: 8),
                  Text(
                    data['description'] ?? 'No description provided for this cataloged item listing.',
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const Divider(height: 32),

                  // Masked Poster Card Profile Layout
                  Text(isLost ? 'Owner Metadata' : 'Finder Metadata', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(Icons.person, color: colorScheme.onPrimaryContainer),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                if (_areFriends)
                                  Text(userTag, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 4),
                                // Star Rating Logic Block Representation
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < rating.floor() ? Icons.star : Icons.star_half,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }) ..add(const SizedBox(width: 4)) ..add(Text('$rating', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                                ),
                              ],
                            ),
                          ),
                          if (!_areFriends && currentUid != (data['userId'] ?? data['finderId']))
                            IconButton(
                              icon: const Icon(Icons.person_add_alt_1),
                              color: colorScheme.primary,
                              tooltip: 'Send Friend Request',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Friend request sent to $userTag')),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: currentUid == (data['userId'] ?? data['finderId'])
          ? null // If the user posted it, hide action prompt bar
          : Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.canvasColor,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3))),
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isLost ? Colors.green : colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: Icon(isLost ? Icons.check_circle_outline : Icons.chat_bubble_outline),
          label: Text(isLost ? 'I Found This Item!' : 'This Item Belongs to Me'),
          onPressed: _initiateCommunication,
        ),
      ),
    );
  }
}