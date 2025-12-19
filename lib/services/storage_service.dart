import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload image to Firebase Storage
  /// Returns the download URL
  Future<String?> uploadImage({
    required String userId,
    required File imageFile,
    String folder = 'profile_photos',
  }) async {
    try {
      // Create unique filename
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      String filePath = '$folder/$userId/$fileName';

      // Upload file
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload image from bytes (for web platform)
  /// Returns the download URL
  Future<String?> uploadImageFromBytes({
    required String userId,
    required Uint8List bytes,
    required String fileName,
    String folder = 'profile_photos',
  }) async {
    try {
      // Create unique filename
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      String filePath = '$folder/$userId/$uniqueFileName';

      // Upload bytes
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image from bytes: $e');
      return null;
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages({
    required String userId,
    required List<File> imageFiles,
    String folder = 'profile_photos',
  }) async {
    List<String> urls = [];
    
    for (File imageFile in imageFiles) {
      String? url = await uploadImage(
        userId: userId,
        imageFile: imageFile,
        folder: folder,
      );
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }

  /// Delete image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Delete multiple images
  Future<void> deleteMultipleImages(List<String> imageUrls) async {
    for (String url in imageUrls) {
      await deleteImage(url);
    }
  }

  /// Get image URL from path (if already uploaded)
  Future<String?> getImageUrl(String filePath) async {
    try {
      Reference ref = _storage.ref().child(filePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting image URL: $e');
      return null;
    }
  }
}

