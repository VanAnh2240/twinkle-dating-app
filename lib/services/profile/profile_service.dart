import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twinkle/models/profile_model.dart';
import 'dart:io';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _profileCollection = 'Profiles';
  
  // ==================== CRUD OPERATIONS ====================

  /// Create a new profile
  Future<bool> createProfile(ProfileModel profile) async {
    try {
      await _firestore
          .collection(_profileCollection)
          .doc(profile.user_id)
          .set(profile.toMap());
      return true;
    } catch (e) {
      print('Error creating profile: $e');
      return false;
    }
  }

  /// Get profile by user ID
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_profileCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return ProfileModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  /// Update entire profile
  Future<bool> updateProfile(ProfileModel profile) async {
    try {
      await _firestore
          .collection(_profileCollection)
          .doc(profile.user_id)
          .set(profile.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  /// Delete profile
  Future<bool> deleteProfile(String userId) async {
    try {
      await _firestore.collection(_profileCollection).doc(userId).delete();
      return true;
    } catch (e) {
      print('Error deleting profile: $e');
      return false;
    }
  }

  /// Check if profile exists
  Future<bool> profileExists(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_profileCollection)
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking profile existence: $e');
      return false;
    }
  }

  // ==================== FIELD UPDATES ====================

  /// Update specific field
  Future<bool> updateField(String userId, String fieldName, dynamic value) async {
    try {
      await _firestore
          .collection(_profileCollection)
          .doc(userId)
          .update({fieldName: value});
      return true;
    } catch (e) {
      print('Error updating field $fieldName: $e');
      return false;
    }
  }

  /// Update bio
  Future<bool> updateBio(String userId, String bio) async {
    return await updateField(userId, 'bio', bio);
  }

  /// Update location
  Future<bool> updateLocation(String userId, String location) async {
    return await updateField(userId, 'location', location);
  }

  // ==================== ABOUT ME OPERATIONS ====================

  /// Add item to about_me array
  Future<bool> addAboutMe(String userId, String item) async {
    try {
      await _firestore
          .collection(_profileCollection)
          .doc(userId)
          .update({
            'about_me': FieldValue.arrayUnion([item]),
          });
      return true;
    } catch (e) {
      print('Error adding about_me: $e');
      return false;
    }
  }

  /// Remove item from about_me array
  Future<bool> removeAboutMe(String userId, String item) async {
    try {
      await _firestore
          .collection(_profileCollection)
          .doc(userId)
          .update({
            'about_me': FieldValue.arrayRemove([item]),
          });
      return true;
    } catch (e) {
      print('Error removing about_me: $e');
      return false;
    }
  }

  /// Set entire about_me array
  Future<bool> setAboutMe(String userId, List<String> items) async {
    return await updateField(userId, 'about_me', items);
  }

  // ==================== INTERESTS OPERATIONS ====================

  /// Add interest
  Future<bool> addInterest(String userId, String interest) async {
    try {
      await _firestore
          .collection(_profileCollection)
          .doc(userId)
          .update({
            'interests': FieldValue.arrayUnion([interest]),
          });
      return true;
    } catch (e) {
      print('Error adding interest: $e');
      return false;
    }
  }

  /// Remove interest
  Future<bool> removeInterest(String userId, String interest) async {
    try {
      await _firestore
          .collection(_profileCollection)
          .doc(userId)
          .update({
            'interests': FieldValue.arrayRemove([interest]),
          });
      return true;
    } catch (e) {
      print('Error removing interest: $e');
      return false;
    }
  }

  /// Set entire interests array
  Future<bool> setInterests(String userId, List<String> interests) async {
    return await updateField(userId, 'interests', interests);
  }

  // ==================== COMMUNITIES OPERATIONS ====================

  /// Add community
  Future<bool> addCommunity(String userId, String community) async {
    try {
      await _firestore
          .collection(_profileCollection)
          .doc(userId)
          .update({
            'communities': FieldValue.arrayUnion([community]),
          });
      return true;
    } catch (e) {
      print('Error adding community: $e');
      return false;
    }
  }

  /// Remove community
  Future<bool> removeCommunity(String userId, String community) async {
    try {
      await _firestore
          .collection(_profileCollection)
          .doc(userId)
          .update({
            'communities': FieldValue.arrayRemove([community]),
          });
      return true;
    } catch (e) {
      print('Error removing community: $e');
      return false;
    }
  }

  /// Set entire communities array
  Future<bool> setCommunities(String userId, List<String> communities) async {
    return await updateField(userId, 'communities', communities);
  }

  // ==================== VALUES OPERATIONS ====================

  /// Add value
  Future<bool> addValue(String userId, String value) async {
    try {
      await _firestore
          .collection(_profileCollection)
          .doc(userId)
          .update({
            'values': FieldValue.arrayUnion([value]),
          });
      return true;
    } catch (e) {
      print('Error adding value: $e');
      return false;
    }
  }

  /// Remove value
  Future<bool> removeValue(String userId, String value) async {
    try {
      await _firestore
          .collection(_profileCollection)
          .doc(userId)
          .update({
            'values': FieldValue.arrayRemove([value]),
          });
      return true;
    } catch (e) {
      print('Error removing value: $e');
      return false;
    }
  }

  /// Set entire values array
  Future<bool> setValues(String userId, List<String> values) async {
    return await updateField(userId, 'values', values);
  }

  // ==================== PHOTO OPERATIONS ====================

  Future<bool> updatePhotoUrl(String userId, String photoUrl) async {
    try {
      await _firestore.collection(_profileCollection).doc(userId).update({
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Could not update photo URL: $e');
      return false;
    }
  }

  Future<bool> removePhotoUrl(String userId) async {
    try {
      await _firestore.collection(_profileCollection).doc(userId).update({
        'photoUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Could not remove photo URL: $e');
      return false;
    }
  }

  /// Add photo URL to profile
  Future<bool> addPhoto(String userId, String photoUrl) async {
    try {
      await _firestore.collection(_profileCollection).doc(userId).update({
        'photos': FieldValue.arrayUnion([photoUrl]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding photo: $e');
      return false;
    }
  }

  /// Remove photo URL from profile
  Future<bool> removePhoto(String userId, String photoUrl) async {
    try {
      await _firestore.collection(_profileCollection).doc(userId).update({
        'photos': FieldValue.arrayRemove([photoUrl]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error removing photo: $e');
      return false;
    }
  }

  /// Update entire photos array
  Future<bool> updatePhotos(String userId, List<String> photoUrls) async {
    return await updateField(userId, 'photos', photoUrls);
  }

  /// Delete all photos for a user
  Future<void> deleteAllPhotos(String userId) async {
    try {
      await _firestore.collection(_profileCollection).doc(userId).update({
        'photos': FieldValue.delete(),
        'photoUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('All photo URLs deleted for user $userId');
    } catch (e) {
      print('Could not delete photo URLs: $e');
    }
  }

  /// Upload and add photo (bỏ storage, chỉ thêm URL)
  Future<bool> uploadAndAddPhoto(String userId, String photoUrl) async {
    return await addPhoto(userId, photoUrl);
  }

  /// Remove and delete photo (chỉ xóa URL trong Firestore)
  Future<bool> removeAndDeletePhoto(String userId, String photoUrl) async {
    return await removePhoto(userId, photoUrl);
  }


  // ==================== QUERY OPERATIONS ====================

  /// Get profiles for discovery (excluding current user)
  Future<List<ProfileModel>> getProfilesForDiscovery({
    required String currentUserId,
    String? locationFilter,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_profileCollection)
          .where('user_id', isNotEqualTo: currentUserId)
          .limit(limit);

      if (locationFilter != null && locationFilter.isNotEmpty) {
        query = query.where('location', isEqualTo: locationFilter);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs
          .map((doc) => ProfileModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting profiles for discovery: $e');
      return [];
    }
  }

  /// Get multiple profiles by user IDs
  Future<List<ProfileModel>> getProfilesByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      // Firestore 'in' query supports max 10 items
      List<ProfileModel> profiles = [];
      
      for (int i = 0; i < userIds.length; i += 10) {
        int end = (i + 10 < userIds.length) ? i + 10 : userIds.length;
        List<String> batch = userIds.sublist(i, end);

        QuerySnapshot snapshot = await _firestore
            .collection(_profileCollection)
            .where('user_id', whereIn: batch)
            .get();

        profiles.addAll(
          snapshot.docs.map(
            (doc) => ProfileModel.fromMap(doc.data() as Map<String, dynamic>)
          )
        );
      }

      return profiles;
    } catch (e) {
      print('Error getting profiles by IDs: $e');
      return [];
    }
  }

  // ==================== REAL-TIME STREAM ====================

  /// Stream profile changes in real-time
  Stream<ProfileModel?> profileStream(String userId) {
    return _firestore
        .collection(_profileCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return ProfileModel.fromMap(doc.data() as Map<String, dynamic>);
          }
          return null;
        });
  }

  /// Stream multiple profiles
  Stream<List<ProfileModel>> profilesStream(List<String> userIds) {
    if (userIds.isEmpty) return Stream.value([]);

    return _firestore
        .collection(_profileCollection)
        .where('user_id', whereIn: userIds)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProfileModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
        });
  }

  // ==================== BATCH OPERATIONS ====================

  /// Update multiple fields at once
  Future<bool> updateMultipleFields(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection(_profileCollection)
          .doc(userId)
          .update(updates);
      return true;
    } catch (e) {
      print('Error updating multiple fields: $e');
      return false;
    }
  }

  /// Initialize profile with default values
  Future<bool> initializeProfile({
    required String userId,
    String location = '',
    String bio = '',
  }) async {
    try {
      ProfileModel initialProfile = ProfileModel(
        user_id: userId,
        location: location,
        bio: bio,
      );
      return await createProfile(initialProfile);
    } catch (e) {
      print('Error initializing profile: $e');
      return false;
    }
  }
}