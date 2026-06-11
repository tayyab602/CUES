import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  
  // 5MB Limit to prevent storage filling up
  static const int maxFileSize = 5 * 1024 * 1024; 

  // Safety guard to prevent "already_active" platform exceptions
  bool _isPickerActive = false;

  // Pick and Crop Image with safety guard
  Future<File?> pickAndCropImage({
    required ImageSource source,
    required BuildContext context,
    bool isProfilePic = false,
  }) async {
    if (_isPickerActive) return null;
    
    _isPickerActive = true;
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, 
      );
      
      if (pickedFile == null) return null;

      // Size check before processing
      final file = File(pickedFile.path);
      if (await file.length() > maxFileSize) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File too large. Max size is 5MB.')),
          );
        }
        return null;
      }

      // WhatsApp-style Cropping
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Image',
            toolbarColor: const Color(0xFF1A365D),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: isProfilePic ? CropAspectRatioPreset.square : CropAspectRatioPreset.original,
            lockAspectRatio: isProfilePic,
            aspectRatioPresets: isProfilePic 
                ? [CropAspectRatioPreset.square]
                : [
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio16x9,
                  ],
          ),
          IOSUiSettings(
            title: 'Edit Image',
            aspectRatioPresets: isProfilePic 
                ? [CropAspectRatioPreset.square]
                : [
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio16x9,
                  ],
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      debugPrint('Picker/Cropper Error: $e');
    } finally {
      _isPickerActive = false;
    }
    return null;
  }

  // Upload with retry logic/safety
  Future<String?> uploadFile(String path, File file) async {
    try {
      if (await file.length() > maxFileSize) {
        debugPrint('Upload blocked: File exceeds 5MB');
        return null;
      }

      final ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      }
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage Error: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('General Upload Error: $e');
    }
    return null;
  }

  // Helper for profile pics
  Future<String?> uploadProfilePic(String uid, File file) => 
      uploadFile('profile_pics/$uid.jpg', file);

  // Helper for item images
  Future<String?> uploadItemImage(String itemId, File file) => 
      uploadFile('item_images/$itemId/${DateTime.now().millisecondsSinceEpoch}.jpg', file);
}
