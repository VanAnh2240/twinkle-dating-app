import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:twinkle/models/profile_model.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/services/firestore_service.dart';
import 'package:twinkle/services/profile_service.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/controllers/auth_controller.dart';

class ProfileSetupController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final ProfileService _profileService = ProfileService();

  // Observable states
  final RxInt currentStep = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  // User data
  final Rx<UsersModel?> user = Rx<UsersModel?>(null);
  final Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  
  // Form data - User info (required)
  final RxString firstName = ''.obs;
  final RxString middleName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString gender = ''.obs;
  final Rx<DateTime?> dateOfBirth = Rx<DateTime?>(null);
  
  // Profile info - PHẢI ĐỒNG NHẤT VỚI ProfileModel
  final RxString bio = ''.obs;
  final RxList<String> photos = <String>[].obs;
  final RxString profilePicture = ''.obs;
  final RxString location = ''.obs;
  final RxList<String> interests = <String>[].obs;
  final RxList<String> aboutMe = <String>[].obs; // Lưu dạng "label: value"
  final RxList<String> communities = <String>[].obs;
  final RxList<String> values = <String>[].obs;
  
  // New fields - temporary storage
  final RxString sexualOrientation = ''.obs;
  final RxBool showSexualOrientationOnProfile = false.obs;
  final RxString interestedIn = ''.obs; // Sẽ lưu vào communities
  final RxList<String> lifestyle = <String>[].obs; // Sẽ lưu vào about_me

  // Steps configuration
  final List<SetupStep> steps = [
    SetupStep(
      id: 'rules',
      title: 'Welcome to Twinkle',
      subtitle: 'Please follow these house rules',
      isRequired: true,
    ),
    SetupStep(
      id: 'name',
      title: 'What\'s your name?',
      subtitle: 'This is how it\'ll appear on your profile',
      isRequired: true,
    ),
    SetupStep(
      id: 'birthday',
      title: 'Your birthday?',
      subtitle: 'Your profile shows your age, not your birth day',
      isRequired: true,
    ),
    SetupStep(
      id: 'gender',
      title: 'What\'s your gender?',
      subtitle: 'Select your gender',
      isRequired: true,
    ),
    SetupStep(
      id: 'location',
      title: 'Where do you live?',
      subtitle: 'Your location helps us connect you with nearby people',
      isRequired: true,
    ),
    SetupStep(
      id: 'sexual_orientation',
      title: 'Your sexual orientation?',
      subtitle: 'Choose your orientation',
      isRequired: false,
    ),
    SetupStep(
      id: 'interested_in',
      title: 'Who are you interested in?',
      subtitle: 'Select who you\'d like to meet',
      isRequired: true,
    ),
    SetupStep(
      id: 'lifestyle',
      title: 'Let\'s talk lifestyle habits!',
      subtitle: 'Do you lean healthy or wild?',
      isRequired: false,
    ),
    SetupStep(
      id: 'about_me',
      title: 'What else makes you-you?',
      subtitle: 'Don\'t hold back. Authentically embrace authenticity.',
      isRequired: false,
    ),
    SetupStep(
      id: 'interests_hobbies',
      title: 'What are you into?',
      subtitle: 'Now, let everyone know.',
      isRequired: false,
    ),
    SetupStep(
      id: 'values',
      title: 'Your values?',
      subtitle: 'What matters most to you?',
      isRequired: false,
    ),
    SetupStep(
      id: 'bio',
      title: 'Tell us about yourself',
      subtitle: 'Write a bio that shows your personality',
      isRequired: false,
    ),
    SetupStep(
      id: 'photos',
      title: 'Add your recent pics',
      subtitle: 'Upload at least 2 photos',
      isRequired: true,
    ),
  ];

  String get userId => Get.find<AuthController>().user?.uid ?? '';
  
  double get progress => (currentStep.value + 1) / steps.length;
  
  bool get canProceed {
    final step = steps[currentStep.value];
    if (!step.isRequired) return true;
    
    switch (step.id) {
      case 'rules':
        return true;
      case 'name':
        return firstName.value.isNotEmpty && lastName.value.isNotEmpty;
      case 'birthday':
        return dateOfBirth.value != null && _isOver18();
      case 'gender':
        return gender.value.isNotEmpty;
      case 'location':
        return location.value.isNotEmpty;
      case 'interested_in':
        return interestedIn.value.isNotEmpty;
      case 'photos':
        return photos.length >= 2 && profilePicture.value.isNotEmpty;
      default:
        return true;
    }
  }

  bool _isOver18() {
    if (dateOfBirth.value == null) return false;
    final now = DateTime.now();
    final age = now.year - dateOfBirth.value!.year;
    if (now.month < dateOfBirth.value!.month ||
        (now.month == dateOfBirth.value!.month && now.day < dateOfBirth.value!.day)) {
      return age - 1 >= 18;
    }
    return age >= 18;
  }

  bool get isLastStep => currentStep.value == steps.length - 1;
  
  bool get hasRequiredData {
    return firstName.value.isNotEmpty &&
           lastName.value.isNotEmpty &&
           gender.value.isNotEmpty &&
           dateOfBirth.value != null &&
           _isOver18() &&
           location.value.isNotEmpty &&
           interestedIn.value.isNotEmpty &&
           photos.length >= 2 &&
           profilePicture.value.isNotEmpty;
  }

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      
      final userData = await _firestoreService.getUserById(userId);
      if (userData != null) {
        user.value = userData;
        firstName.value = userData.first_name;
        lastName.value = userData.last_name;
        gender.value = userData.gender;
        dateOfBirth.value = userData.date_of_birth;
        profilePicture.value = userData.profile_picture;
      }

      // Sử dụng ProfileService thay vì FirestoreService
      final profileData = await _profileService.getProfile(userId);
      if (profileData != null) {
        profile.value = profileData;
        bio.value = profileData.bio;
        photos.value = profileData.photos;
        location.value = profileData.location;
        interests.value = profileData.interests;
        aboutMe.value = profileData.about_me;
        communities.value = profileData.communities;
        values.value = profileData.values;
        
        // Parse interestedIn từ communities nếu có
        if (communities.isNotEmpty) {
          interestedIn.value = communities.first;
        }
        
        // Parse lifestyle từ about_me nếu có
        _parseLifestyleFromAboutMe();
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to load user data');
    } finally {
      isLoading.value = false;
    }
  }

  void _parseLifestyleFromAboutMe() {
    // Parse các lifestyle items từ about_me list
    for (var item in aboutMe) {
      if (item.startsWith('Drinking: ') || 
          item.startsWith('Smoking: ') || 
          item.startsWith('Exercise: ')) {
        final value = item.split(': ').last;
        if (!lifestyle.contains(value)) {
          lifestyle.add(value);
        }
      }
    }
  }

  void nextStep() async {
    if (!canProceed && steps[currentStep.value].isRequired) {
      Get.snackbar(
        'Required',
        'Please complete this step before continuing',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Save current step data
    await saveCurrentStep();

    if (isLastStep) {
      await completeSetup();
    } else {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void skipStep() {
    if (steps[currentStep.value].isRequired) {
      Get.snackbar(
        'Cannot Skip',
        'This step is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    nextStep();
  }

  Future<void> saveCurrentStep() async {
    try {
      isLoading.value = true;
      
      final step = steps[currentStep.value];
      
      switch (step.id) {
        case 'name':
          // Lưu vào Users collection
          await _firestoreService.updateUserPartial(userId, {
            'first_name': firstName.value,
            'last_name': lastName.value,
          });
          break;
          
        case 'birthday':
          // Lưu vào Users collection
          await _firestoreService.updateUserPartial(userId, {
            'date_of_birth': dateOfBirth.value != null 
                ? Timestamp.fromDate(dateOfBirth.value!)
                : null,
          });
          break;
          
        case 'gender':
          // Lưu vào Users collection
          await _firestoreService.updateUserPartial(userId, {
            'gender': gender.value,
          });
          // Thêm gender vào about_me
          _updateAboutMeField('Gender', gender.value);
          await _profileService.setAboutMe(userId, aboutMe.toList());
          break;
          
        case 'location':
          // Lưu vào Profile collection
          await _profileService.updateLocation(userId, location.value);
          break;
          
        case 'sexual_orientation':
          if (sexualOrientation.value.isNotEmpty) {
            // Lưu vào about_me
            _updateAboutMeField('Sexual Orientation', sexualOrientation.value);
            await _profileService.setAboutMe(userId, aboutMe.toList());
          }
          break;
          
        case 'interested_in':
          // Lưu vào communities (hoặc có thể tạo field riêng)
          if (!communities.contains(interestedIn.value)) {
            await _profileService.addCommunity(userId, interestedIn.value);
            communities.add(interestedIn.value);
          }
          // Hoặc lưu vào about_me
          _updateAboutMeField('Looking for', interestedIn.value);
          await _profileService.setAboutMe(userId, aboutMe.toList());
          break;
          
        case 'lifestyle':
          // Lưu lifestyle vào about_me với format "label: value"
          for (var item in lifestyle) {
            // Xác định xem item thuộc category nào
            if (item.contains('drink') || item.contains('alcohol')) {
              _updateAboutMeField('Drinking', item);
            } else if (item.contains('smoke') || item.contains('cigarette')) {
              _updateAboutMeField('Smoking', item);
            } else if (item.contains('exercise') || item.contains('gym')) {
              _updateAboutMeField('Exercise', item);
            }
          }
          await _profileService.setAboutMe(userId, aboutMe.toList());
          break;
          
        case 'about_me':
          // aboutMe đã được update trực tiếp, chỉ cần save
          await _profileService.setAboutMe(userId, aboutMe.toList());
          break;
          
        case 'interests_hobbies':
          // Lưu vào Profile collection
          await _profileService.setInterests(userId, interests.toList());
          break;
          
        case 'values':
          // Lưu vào Profile collection
          await _profileService.setValues(userId, values.toList());
          break;
          
        case 'bio':
          // Lưu vào Profile collection
          await _profileService.updateBio(userId, bio.value);
          break;
          
        case 'photos':
          // Lưu profile_picture vào Users collection
          await _firestoreService.updateUserPartial(userId, {
            'profile_picture': profilePicture.value,
          });
          // Lưu photos vào Profile collection
          await _profileService.updatePhotos(userId, photos.toList());
          break;
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to save data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Helper method để update about_me field theo format "label: value"
  void _updateAboutMeField(String label, String value) {
    // Remove old entry with same label
    aboutMe.removeWhere((item) => item.startsWith('$label: '));
    // Add new entry
    if (value.isNotEmpty) {
      aboutMe.add('$label: $value');
    }
  }

  Future<void> completeSetup() async {
    if (!hasRequiredData) {
      Get.snackbar(
        'Incomplete',
        'Please complete all required fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      // Final save - Tạo/Update toàn bộ profile
      final completeProfile = ProfileModel(
        user_id: userId,
        bio: bio.value.trim(),
        location: location.value.trim(),
        about_me: aboutMe.toList(),
        interests: interests.toList(),
        communities: communities.toList(),
        values: values.toList(),
        photos: photos.toList(),
      );
      
      // Sử dụng ProfileService để lưu
      final profileExists = await _profileService.profileExists(userId);
      
      if (profileExists) {
        await _profileService.updateProfile(completeProfile);
      } else {
        await _profileService.createProfile(completeProfile);
      }
      
      // Navigate to main page
      Get.offAllNamed(AppRoutes.main);
      
      Get.snackbar(
        'Success',
        'Profile setup completed!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to complete setup: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setProfilePicture(String photoUrl) {
    profilePicture.value = photoUrl;
    if (!photos.contains(photoUrl)) {
      photos.insert(0, photoUrl);
    }
  }

  void addPhoto(String photoUrl) {
    if (!photos.contains(photoUrl)) {
      photos.add(photoUrl);
    }
    if (profilePicture.value.isEmpty && photos.isNotEmpty) {
      profilePicture.value = photos.first;
    }
  }

  void removePhoto(String photoUrl) {
    photos.remove(photoUrl);
    if (profilePicture.value == photoUrl && photos.isNotEmpty) {
      profilePicture.value = photos.first;
    } else if (photos.isEmpty) {
      profilePicture.value = '';
    }
  }

  void toggleInterest(String interest) {
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
  }

  void toggleAboutMeMultiple(String label, String value) {
    final entry = '$label: $value';
    
    if (aboutMe.contains(entry)) {
      aboutMe.remove(entry);
    } else {
      aboutMe.add(entry);
    }
  }

  void toggleValue(String value) {
    if (values.contains(value)) {
      values.remove(value);
    } else {
      values.add(value);
    }
  }

  void toggleLifestyle(String item) {
    if (lifestyle.contains(item)) {
      lifestyle.remove(item);
    } else {
      lifestyle.add(item);
    }
  }
}

class SetupStep {
  final String id;
  final String title;
  final String subtitle;
  final bool isRequired;

  SetupStep({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isRequired,
  });
}