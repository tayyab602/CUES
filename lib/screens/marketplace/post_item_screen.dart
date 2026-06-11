import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_button.dart';

class PostItemScreen extends StatefulWidget {
  const PostItemScreen({super.key});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;
  bool _isPickingImage = false; // Guard flag

  final _storageService = StorageService();
  final List<File> _selectedImages = [];

  final List<String> _categories = [
    'Books', 'Electronics', 'Hostel Items', 'Clothing', 'Stationery', 'Sports', 'Other',
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
        setState(() => _selectedImages.add(file));
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _postItem() async {
    if (_titleController.text.trim().isEmpty || _descController.text.trim().isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final List<String> imageUrls = [];
      final docId = FirebaseFirestore.instance.collection('items').doc().id;

      for (var imageFile in _selectedImages) {
        final url = await _storageService.uploadItemImage(docId, imageFile);
        if (url != null) imageUrls.add(url);
      }

      await FirebaseFirestore.instance.collection('items').doc(docId).set({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0,
        'category': _selectedCategory,
        'images': imageUrls,
        'sellerId': uid,
        'status': 'available',
        'createdAt': DateTime.now().toIso8601String(),
        'expiresAt': DateTime.now().add(const Duration(days: 30)).toIso8601String(), // Auto-delete logic
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item posted successfully!'), backgroundColor: Colors.green),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Post Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Image Selection Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  if (_selectedImages.isEmpty)
                    IconButton(
                      icon: const Icon(Icons.add_photo_alternate, size: 40),
                      onPressed: _pickImage,
                      color: colorScheme.primary,
                    )
                  else
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _selectedImages.length) {
                            return IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: _pickImage,
                            );
                          }
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(_selectedImages[index], width: 100, height: 100, fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedImages.removeAt(index)),
                                  child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text('Add photos of your item', style: TextStyle(color: colorScheme.secondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Item Title *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.title)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (PKR)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money), hintText: '0 for free'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category)),
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 28),
            CustomButton(label: 'Post Item', onPressed: _postItem, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
