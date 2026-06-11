import 'package:flutter/material.dart';
import 'claim_service.dart';
import '../../widgets/custom_button.dart';

class SendClaimScreen extends StatefulWidget {
  final String itemId;
  final String ownerId;
  final String itemTitle;
  final String type; // 'lost' or 'marketplace'

  const SendClaimScreen({
    super.key,
    required this.itemId,
    required this.ownerId,
    required this.itemTitle,
    required this.type,
  });

  @override
  State<SendClaimScreen> createState() => _SendClaimScreenState();
}

class _SendClaimScreenState extends State<SendClaimScreen> {
  final _descController = TextEditingController();
  final _claimService = ClaimService();
  bool _isLoading = false;

  Future<void> _submitClaim() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe why this item belongs to you'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _claimService.sendClaim(
        itemId: widget.itemId,
        ownerId: widget.ownerId,
        type: widget.type,
        description: _descController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Claim sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Claim Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Claiming:',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.itemTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.type.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Why does this item belong to you?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Provide specific details that prove ownership — '
                  'serial number, unique marks, purchase details, etc.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText:
                'e.g. This is my laptop. Serial number is XYZ123. '
                    'I bought it in January 2024 from...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'False claims may result in account suspension.',
                      style:
                      TextStyle(color: Colors.orange, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            CustomButton(
              label: 'Submit Claim',
              onPressed: _submitClaim,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}