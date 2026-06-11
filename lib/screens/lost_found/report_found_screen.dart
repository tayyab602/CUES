import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_button.dart';

class ReportFoundScreen extends StatefulWidget {
  const ReportFoundScreen({super.key});

  @override
  State<ReportFoundScreen> createState() => _ReportFoundScreenState();
}

class _ReportFoundScreenState extends State<ReportFoundScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;
  bool _isPickingImage = false;

  final _storageService = StorageService();
  File? _selectedImage; //  FIXED: Enforced single image model to optimize storage footprint

  final List<String> _categories = [
    'Electronics', 'Books', 'Wallet/Purse', 'Keys',
    'ID Card', 'Clothing', 'Bag', 'Other',
  ];

  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    setState(() => _isPickingImage = true);
    try {
      final file = await _storageService.pickAndCropImage(
        source: ImageSource.gallery,
        context: context,
        isProfilePic: false,
      );
      if (file != null) {
        setState(() => _selectedImage = file);
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      List<String> imageUrls = [];
      //  FIXED: Routing all reports into the unified 'items' collection
      final docId = FirebaseFirestore.instance.collection('items').doc().id;

      if (_selectedImage != null) {
        final url = await _storageService.uploadItemImage(docId, _selectedImage!);
        if (url != null) imageUrls.add(url);
      }

      await FirebaseFirestore.instance.collection('items').doc(docId).set({
        'itemId': docId,
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'location': _locationController.text.trim(),
        'category': _selectedCategory,
        'images': imageUrls, // Keeps array mapping intact so feed queries read cleanly
        'finderId': uid,
        'userId': uid, // Map both fields to prevent null pointer crashes on cross-reads
        'type': 'found', //  FIXED: Explicit discriminator tag for unified stream separation
        'status': 'unclaimed',
        'createdAt': DateTime.now().toIso8601String(),
        'expiresAt': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Found item reported successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Found Item'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  if (_selectedImage == null)
                    IconButton(
                      icon: const Icon(Icons.add_a_photo, size: 40),
                      onPressed: _pickImage,
                      color: Colors.green,
                    )
                  else
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_selectedImage!, width: 120, height: 120, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImage = null),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text('Add photos of the found item', style: TextStyle(color: colorScheme.secondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildField(_titleController, 'What item did you find? *', Icons.title),
            const SizedBox(height: 16),
            _buildField(_descController, 'Describe item characteristics *', Icons.description, maxLines: 3),
            const SizedBox(height: 16),
            _buildField(_locationController, 'Where did you find this item? *', Icons.location_on),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 28),

            CustomButton(
              label: 'Report Found Item',
              onPressed: _submit,
              isLoading: _isLoading,
              // Match theme palette parameters elegantly
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}