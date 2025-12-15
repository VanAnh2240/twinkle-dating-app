import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twinkle/models/profile_model.dart';
import 'package:twinkle/services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Observable variables
  final Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingPhoto = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Form fields - corresponding to ProfileModel
  final RxString bio = ''.obs;
  final RxString location = ''.obs;
  final RxList<String> aboutMe = <String>[].obs;
  final RxList<String> interests = <String>[].obs;
  final RxList<String> communities = <String>[].obs;
  final RxList<String> values = <String>[].obs;
  final RxList<String> photos = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }

  // ==================== PROFILE LOADING ====================

  /// Load profile from Firestore
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      String userId = getCurrentUserId();
      if (userId.isEmpty) {
        throw Exception('User not logged in');
      }
      
      ProfileModel? loadedProfile = await _profileService.getProfile(userId);
      
      if (loadedProfile != null) {
        profile.value = loadedProfile;
        _populateFormFields(loadedProfile);
      } else {
        // Create initial profile if doesn't exist
        await _createInitialProfile();
      }
    } catch (e) {
      errorMessage.value = 'Error loading profile: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Create initial profile
  Future<void> _createInitialProfile() async {
    try {
      String userId = getCurrentUserId();
      bool success = await _profileService.initializeProfile(userId: userId);
      
      if (success) {
        ProfileModel? newProfile = await _profileService.getProfile(userId);
        if (newProfile != null) {
          profile.value = newProfile;
          _populateFormFields(newProfile);
        }
      }
    } catch (e) {
      print('Error creating initial profile: $e');
    }
  }

  // ==================== PROFILE SAVING ====================

  /// Save entire profile
  Future<void> saveProfile() async {
    if (!validateProfile()) return;

    try {
      isSaving.value = true;
      errorMessage.value = '';

      String userId = getCurrentUserId();
      
      ProfileModel updatedProfile = ProfileModel(
        user_id: userId,
        bio: bio.value.trim(),
        location: location.value.trim(),
        about_me: aboutMe.toList(),
        interests: interests.toList(),
        communities: communities.toList(),
        values: values.toList(),
        photos: photos.toList(),
      );

      bool success = await _profileService.updateProfile(updatedProfile);

      if (success) {
        profile.value = updatedProfile;
        Get.snackbar(
          'Success',
          'Profile saved successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Failed to save profile');
      }
    } catch (e) {
      errorMessage.value = 'Error saving profile: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Validate profile before saving
  bool validateProfile() {
    if (location.value.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your location',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    if (photos.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please add at least 1 photo',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    if (bio.value.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please write a bio',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    return true;
  }

  // ==================== FIELD UPDATES ====================

  /// Update bio
  Future<void> updateBio(String newBio) async {
    bio.value = newBio;
    await _profileService.updateBio(getCurrentUserId(), newBio);
  }

  /// Update location
  Future<void> updateLocation(String newLocation) async {
    location.value = newLocation;
    await _profileService.updateLocation(getCurrentUserId(), newLocation);
  }

  // ==================== ABOUT ME ====================

  /// Toggle About Me item
  Future<void> toggleAboutMe(String item) async {
    String userId = getCurrentUserId();
    
    if (aboutMe.contains(item)) {
      aboutMe.remove(item);
      await _profileService.removeAboutMe(userId, item);
    } else {
      aboutMe.add(item);
      await _profileService.addAboutMe(userId, item);
    }
  }

  // ==================== INTERESTS ====================

  /// Toggle Interest item
  Future<void> toggleInterest(String item) async {
    String userId = getCurrentUserId();
    
    if (interests.contains(item)) {
      interests.remove(item);
      await _profileService.removeInterest(userId, item);
    } else {
      interests.add(item);
      await _profileService.addInterest(userId, item);
    }
  }

  // ==================== COMMUNITIES ====================

  /// Toggle Community item
  Future<void> toggleCommunity(String item) async {
    String userId = getCurrentUserId();
    
    if (communities.contains(item)) {
      communities.remove(item);
      await _profileService.removeCommunity(userId, item);
    } else {
      communities.add(item);
      await _profileService.addCommunity(userId, item);
    }
  }

  // ==================== VALUES ====================

  /// Toggle Value item
  Future<void> toggleValue(String item) async {
    String userId = getCurrentUserId();
    
    if (values.contains(item)) {
      values.remove(item);
      await _profileService.removeValue(userId, item);
    } else {
      values.add(item);
      await _profileService.addValue(userId, item);
    }
  }

  // ==================== PHOTO OPERATIONS ====================

  /// Pick and upload single image
  Future<void> pickAndUploadImage() async {
    if (photos.length >= 6) {
      Get.snackbar(
        'Limit Reached',
        'Maximum 6 photos allowed',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        isUploadingPhoto.value = true;
        String imageUrl = image.path; 
        bool success = await _profileService.uploadAndAddPhoto(
          getCurrentUserId(),
          imageUrl, // truyền String URL trực tiếp
        );

        if (success) {
          photos.add(imageUrl);
          Get.snackbar(
            'Success',
            'Photo added successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to add photo',
            snackPosition: SnackPosition.BOTTOM,
          );
        }

        isUploadingPhoto.value = false;
      }

    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not upload photo: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  /// Pick and upload multiple images
  Future<void> pickMultipleImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isEmpty) return;

      isUploadingPhoto.value = true;
      int uploadedCount = 0;
      String userId = getCurrentUserId();
      
      for (XFile image in images) {
        if (photos.length >= 6) {
          Get.snackbar(
            'Limit Reached',
            'Maximum 6 photos allowed',
            snackPosition: SnackPosition.BOTTOM,
          );
          break;
        }

        String imageUrl = image.path; 

        bool success = await _profileService.addPhoto(userId, imageUrl);

        if (success) {
          photos.add(imageUrl);
          uploadedCount++;
        } else {
          Get.snackbar(
            'Error',
            'Failed to add photo: ${image.name}',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }


      Get.snackbar(
        'Success',
        '$uploadedCount photo(s) uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not upload photos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  /// Remove photo at index
  Future<void> removePhoto(int index) async {
    if (index < 0 || index >= photos.length) return;

    try {
      String photoUrl = photos[index];
      
      bool success = await _profileService.removeAndDeletePhoto(
        getCurrentUserId(),
        photoUrl,
      );
      
      if (success) {
        photos.removeAt(index);
        Get.snackbar(
          'Success',
          'Photo removed successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not remove photo: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Reorder photos (drag and drop)
  Future<void> reorderPhotos(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final String item = photos.removeAt(oldIndex);
    photos.insert(newIndex, item);
    
    await _profileService.updatePhotos(getCurrentUserId(), photos.toList());
  }

  // ==================== PROFILE MANAGEMENT ====================

  /// Delete entire profile
  Future<void> deleteProfile() async {
    try {
      bool success = await _profileService.deleteProfile(getCurrentUserId());
      
      if (success) {
        profile.value = null;
        _clearFormFields();
        Get.snackbar(
          'Success',
          'Profile deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ==================== HELPERS ====================

  /// Check if profile is complete
  bool get isProfileComplete {
    return profile.value?.isComplete ?? false;
  }

  /// Get avatar URL (first photo)
  String get avatarUrl {
    return photos.isNotEmpty ? photos.first : '';
  }

  /// Populate form fields from profile
  void _populateFormFields(ProfileModel profile) {
    bio.value = profile.bio;
    location.value = profile.location;
    aboutMe.value = profile.about_me;
    interests.value = profile.interests;
    communities.value = profile.communities;
    values.value = profile.values;
    photos.value = profile.photos;
  }

  /// Clear all form fields
  void _clearFormFields() {
    bio.value = '';
    location.value = '';
    aboutMe.clear();
    interests.clear();
    communities.clear();
    values.clear();
    photos.clear();
  }

  /// Get current user ID from Firebase Auth
  String getCurrentUserId() {
    return _auth.currentUser?.uid ?? '';
  }
}