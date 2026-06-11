import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'claim_service.dart';

class ClaimsScreen extends StatelessWidget {
  const ClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Claims'),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Color(0xFFFF8A00),
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.inbox), text: 'Received'),
              Tab(icon: Icon(Icons.send), text: 'Sent'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ReceivedClaimsTab(),
            _SentClaimsTab(),
          ],
        ),
      ),
    );
  }
}

// RECEIVED CLAIMS TAB
class _ReceivedClaimsTab extends StatelessWidget {
  const _ReceivedClaimsTab();

  @override
  Widget build(BuildContext context) {
    final claimService = ClaimService();

    return StreamBuilder<QuerySnapshot>(
      stream: claimService.getReceivedClaims(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('No claims received',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _ReceivedClaimCard(
              claimId: docs[index].id,
              data: data,
              claimService: claimService,
            );
          },
        );
      },
    );
  }
}

class _ReceivedClaimCard extends StatelessWidget {
  final String claimId;
  final Map<String, dynamic> data;
  final ClaimService claimService;

  const _ReceivedClaimCard({
    required this.claimId,
    required this.data,
    required this.claimService,
  });

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'pending';
    final isPending = status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(data['requesterId'])
                      .get(),
                  builder: (context, snap) {
                    final user =
                    snap.data?.data() as Map<String, dynamic>?;
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            (user?['name'] ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?['name'] ?? 'User',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              user?['department'] ?? '',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                _StatusBadge(status: status),
              ],
            ),
            const Divider(height: 20),

            // Item info
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection(data['type'] == 'marketplace'
                      ? 'items'
                      : (data['type'] == 'found' ? 'foundItems' : 'lostItems'))
                  .doc(data['itemId'])
                  .get(),
              builder: (context, snap) {
                final item = snap.data?.data() as Map<String, dynamic>?;
                return Text(
                  'Item: ${item?['title'] ?? 'Unknown'}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                );
              },
            ),
            const SizedBox(height: 8),

            // Description
            const Text(
              'Claim reason:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              data['description'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Action buttons (only if pending)
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await claimService.rejectClaim(claimId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Claim rejected'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Reject',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await claimService.approveClaim(
                          claimId: claimId,
                          itemId: data['itemId'],
                          type: data['type'],
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Claim approved!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// SENT CLAIMS TAB
class _SentClaimsTab extends StatelessWidget {
  const _SentClaimsTab();

  @override
  Widget build(BuildContext context) {
    final claimService = ClaimService();

    return StreamBuilder<QuerySnapshot>(
      stream: claimService.getSentClaims(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('No claims sent',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection(data['type'] == 'marketplace'
                                  ? 'items'
                                  : (data['type'] == 'found'
                                      ? 'foundItems'
                                      : 'lostItems'))
                              .doc(data['itemId'])
                              .get(),
                          builder: (context, snap) {
                            final item = snap.data?.data()
                            as Map<String, dynamic>?;
                            return Expanded(
                              child: Text(
                                item?['title'] ?? 'Unknown Item',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                        _StatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['description'] ?? '',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Type: ${data['type']?.toUpperCase() ?? ''}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary, 
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Status Badge widget
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color color;
    IconData icon;

    switch (status) {
      case 'approved':
        color = const Color(0xFF10B981); // Emerald Green
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = colorScheme.error; // Crimson Red
        icon = Icons.cancel;
        break;
      default:
        color = colorScheme.tertiary; // Safety Orange
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
                color: color, 
                fontSize: 10, 
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
