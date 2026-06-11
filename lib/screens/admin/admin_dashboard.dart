import 'package:flutter/material.dart';
import 'admin_service.dart';
import 'admin_users_screen.dart';
import 'admin_items_screen.dart';
import 'admin_claims_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Block Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 36),
                  SizedBox(height: 8),
                  Text(
                    'CUES Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Campus Utility Exchange System',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // System Metrics Section
            const Text(
              'System Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            FutureBuilder<Map<String, int>>(
              future: adminService.getStats(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stats = snapshot.data!;

                // Structured mapping array for unified metric cards population
                final List<Map<String, dynamic>> metricGrid = [
                  {'label': 'Total Users', 'value': stats['users'] ?? 0, 'icon': Icons.people, 'color': Colors.blue},
                  {'label': 'Marketplace Items', 'value': stats['items'] ?? 0, 'icon': Icons.store, 'color': Colors.orange},
                  {'label': 'Lost Items', 'value': stats['lostItems'] ?? 0, 'icon': Icons.search_off, 'color': Colors.red},
                  {'label': 'Found Items', 'value': stats['foundItems'] ?? 0, 'icon': Icons.find_in_page, 'color': Colors.green},
                  {'label': 'Total Claims', 'value': stats['claims'] ?? 0, 'icon': Icons.assignment, 'color': Colors.purple},
                  {'label': 'Active Chats', 'value': stats['chats'] ?? 0, 'icon': Icons.chat, 'color': Colors.teal},
                  {'label': 'Items Sold', 'value': stats['soldItems'] ?? 0, 'icon': Icons.check_circle, 'color': Colors.indigo},
                  {'label': 'Claims Resolved', 'value': stats['approvedClaims'] ?? 0, 'icon': Icons.verified, 'color': Colors.cyan},
                ];

                //  FIXED: Converted from rigid GridView.count to dynamic adaptive builder mapping layout
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: metricGrid.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 105, //  FIXED: Enforces explicit logical pixels height to eliminate overflow risk
                  ),
                  itemBuilder: (context, index) {
                    final card = metricGrid[index];
                    return _StatCard(
                      label: card['label'] as String,
                      value: card['value'] as int,
                      icon: card['icon'] as IconData,
                      color: card['color'] as Color,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Management Panels Navigation Section
            const Text(
              'Manage System Systems',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _ManageCard(
              icon: Icons.people,
              title: 'Users',
              subtitle: 'View, ban or remove users',
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
              ),
            ),
            _ManageCard(
              icon: Icons.store,
              title: 'Marketplace Items',
              subtitle: 'Remove inappropriate listings',
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminItemsScreen(type: 'marketplace')),
              ),
            ),
            _ManageCard(
              icon: Icons.search_off,
              title: 'Lost & Found Items',
              subtitle: 'Monitor lost and found reports',
              color: Colors.red,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminItemsScreen(type: 'lostfound')),
              ),
            ),
            _ManageCard(
              icon: Icons.assignment,
              title: 'Claims',
              subtitle: 'Monitor all claim requests',
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminClaimsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row( //  FIXED: Changed to horizontal Row structure to handle numerical layout tracking smoothly
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ManageCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}