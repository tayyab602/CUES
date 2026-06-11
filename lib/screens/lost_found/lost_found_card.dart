import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/chat_service.dart';
import '../../services/item_service.dart';
import '../chat/chat_screen.dart';
import 'item_detail_screen.dart'; //  ADDED: Import your newly built details screen viewport

class LostFoundCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String id;
  final String type;

  const LostFoundCard({
    super.key,
    required this.data,
    required this.id,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLost = type == 'lost';

    final statusColor = isLost ? colorScheme.error : const Color(0xFF10B981);
    final images = data['images'] as List<dynamic>? ?? [];

    String timeAgo = '';
    if (data['createdAt'] != null) {
      try {
        final date = DateTime.parse(data['createdAt']);
        timeAgo = DateFormat('MMM d, h:mm a').format(date);
      } catch (_) {
        timeAgo = 'Recently';
      }
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.4),
          width: 1,
        ),
      ),
      //  FIXED: Removed broken free floating code block and integrated navigation cleanly into the InkWell body
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          //  FIXED: Tapping the card opens up the full specification view
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemDetailScreen(itemData: data),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Preview
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: images.isNotEmpty && images[0].toString().isNotEmpty
                    ? Image.network(
                  images[0],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(statusColor),
                )
                    : _placeholder(statusColor),
              ),
              const SizedBox(width: 16),

              // Content Box
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withOpacity(0.2)),
                          ),
                          child: Text(
                            isLost ? 'LOST' : 'FOUND',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Text(
                          data['category']?.toString().toUpperCase() ?? '',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Text(
                      data['title'] ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),
                    Text(
                      data['description'] ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${data['location'] ?? 'Unknown'} • $timeAgo',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    if ((isLost ? data['userId'] : data['finderId']) != FirebaseAuth.instance.currentUser?.uid) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: FilledButton(
                          onPressed: () async {
                            final chatService = ChatService();
                            final peerId = isLost ? data['userId'] : data['finderId'];
                            final chatId = await chatService.startItemChat(peerId, id);

                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    chatId: chatId,
                                    otherUserId: peerId,
                                    chatType: 'item',
                                  ),
                                ),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: isLost ? colorScheme.primary : const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          child: Text(
                            isLost ? 'I found this' : 'This is mine',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Resolve Item'),
                                content: const Text('Is this item recovered or found? This will permanently delete the post and archive active chats.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Resolve', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final itemService = ItemService();
                              final firstImage = images.isNotEmpty ? images[0] : '';
                              //  FIXED: Pointing strictly to the unified structural 'items' collection parameters
                              await itemService.resolveItem(
                                id,
                                firstImage,
                                collection: 'items',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Item resolved and cleaned up.')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('Resolve & Close'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(Color color) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, color: color.withOpacity(0.6), size: 32),
          const SizedBox(height: 4),
          Text(
            'NO IMAGE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}