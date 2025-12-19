import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:twinkle/models/profile_model.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/services/firestore_service.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/controllers/auth_controller.dart';

class ProfileSetupController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

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
  
  // Profile info
  final RxString bio = ''.obs;
  final RxList<String> photos = <String>[].obs;
  final RxString profilePicture = ''.obs;
  final RxString location = ''.obs;
  final RxList<String> interests = <String>[].obs;
  final RxList<String> aboutMe = <String>[].obs;
  final RxList<String> communities = <String>[].obs;
  final RxList<String> values = <String>[].obs;
  
  // New fields
  final RxString sexualOrientation = ''.obs;
  final RxBool showSexualOrientationOnProfile = false.obs;
  final RxString interestedIn = ''.obs; // Who are you interested in
  final RxList<String> lifestyle = <String>[].obs;

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
        return true; // Just need to press I agree
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

      final profileData = await _firestoreService.getUserProfile(userId);
      if (profileData != null) {
        profile.value = profileData;
        bio.value = profileData.bio;
        photos.value = profileData.photos;
        location.value = profileData.location;
        interests.value = profileData.interests;
        aboutMe.value = profileData.about_me;
        communities.value = profileData.communities;
        values.value = profileData.values;
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to load user data');
    } finally {
      isLoading.value = false;
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
          await _firestoreService.updateUserFields(userId, {
            'first_name': firstName.value,
            'last_name': lastName.value,
          });
          break;
          
        case 'birthday':
          await _firestoreService.updateUserFields(userId, {
            'date_of_birth': dateOfBirth.value != null 
                ? Timestamp.fromDate(dateOfBirth.value!)
                : null,
          });
          break;
          
        case 'gender':
          await _firestoreService.updateUserFields(userId, {
            'gender': gender.value,
          });
          break;
          
        case 'photos':
          await _firestoreService.updateUserFields(userId, {
            'profile_picture': profilePicture.value,
          });
          await updateOrCreateProfile({'photos': photos.toList()});
          break;
          
        case 'location':
          await updateOrCreateProfile({'location': location.value});
          break;
          
        case 'bio':
          await updateOrCreateProfile({'bio': bio.value});
          break;
          
        case 'interests_hobbies':
          await updateOrCreateProfile({'interests': interests.toList()});
          break;
          
        case 'about_me':
          await updateOrCreateProfile({'about_me': aboutMe.toList()});
          break;
          
        case 'interested_in':
          await updateOrCreateProfile({'communities': [interestedIn.value]});
          break;
          
        case 'values':
          await updateOrCreateProfile({'values': values.toList()});
          break;
          
        case 'lifestyle':
          // Save lifestyle to about_me or create new field
          break;
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to save data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrCreateProfile(Map<String, dynamic> data) async {
    final profileExists = await _firestoreService.profileExists(userId);
    
    if (profileExists) {
      await _firestoreService.updateProfileFields(userId, data);
    } else {
      final newProfile = ProfileModel(
        user_id: userId,
        bio: data['bio'] ?? '',
        photos: data['photos'] ?? [],
        location: data['location'] ?? '',
        interests: data['interests'] ?? [],
        about_me: data['about_me'] ?? [],
        communities: data['communities'] ?? [],
        values: data['values'] ?? [],
      );
      await _firestoreService.createProfile(userId, newProfile);
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
      
      // Final save
      await saveCurrentStep();
      
      // Navigate to main page
      Get.offAllNamed(AppRoutes.main);
      
      Get.snackbar(
        'Success',
        'Profile setup completed!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to complete setup');
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
    // If no profile picture set, use first photo
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

  void toggleAboutMe(String item) {
    if (aboutMe.contains(item)) {
      aboutMe.remove(item);
    } else {
      aboutMe.add(item);
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