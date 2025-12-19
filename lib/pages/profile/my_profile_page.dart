import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/services/firestore_service.dart';
import 'package:twinkle/models/profile_model.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/services/profile/profile_service.dart';
import 'package:twinkle/services/profile/storage_service.dart';
import 'package:twinkle/themes/theme.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> with SingleTickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final FirestoreService _firestoreService = Get.put(FirestoreService());
  final ProfileService _profileService = ProfileService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  
  late TabController _tabController;
  UsersModel? _user;
  ProfileModel? _profile;
  bool _isLoading = true;
  
  // Edit Profile State
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _communityController = TextEditingController();
  List<String> _interests = [];
  List<String> _communities = [];
  List<String> _values = [];
  List<String> _photos = [];
  Map<String, String> _aboutMe = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bioController.dispose();
    _interestController.dispose();
    _communityController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final currentID = authController.user!.uid;
    final user = await _firestoreService.getUserById(currentID);
    final profile = await _profileService.getProfile(currentID);
    
    setState(() {
      _user = user;
      _profile = profile ?? ProfileModel(user_id: currentID);
      _bioController.text = _profile!.bio;
      _interests = List.from(_profile!.interests);
      _communities = List.from(_profile!.communities);
      _values = List.from(_profile!.values);
      _photos = List.from(_profile!.photos);
      _isLoading = false;
    });
  }

  int _calculateProfileStrength() {
    int score = 0;
    if (_bioController.text.isNotEmpty) score += 10;
    if (_photos.length > 0) score += 20;
    if (_photos.length >= 3) score += 10;
    if (_interests.length > 0) score += 15;
    if (_interests.length >= 3) score += 5;
    if (_communities.length >= 3) score += 10;
    if (_values.length >= 3) score += 10;
    if (_aboutMe.isNotEmpty) score += 10;
    if (_profile?.location != null && _profile!.location.isNotEmpty) score += 10;
    return score > 100 ? 100 : score;
  }

  Future<void> _pickImage() async {
    if (_photos.length >= 6) {
      Get.snackbar('Info', 'Maximum 6 photos allowed', backgroundColor: Colors.blue, colorText: Colors.white);
      return;
    }
    
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final imageFile = File(image.path);
        final userId = authController.user!.uid;
        
        // Show loading
        Get.dialog(
          Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
          barrierDismissible: false,
        );
        
        // Upload to Firebase Storage
        final downloadUrl = await _storageService.uploadImage(
          userId: userId,
          imageFile: imageFile,
          folder: 'profile_photos',
        );
        
        Get.back(); // Close loading dialog
        
        if (downloadUrl != null) {
          setState(() {
            _photos.add(downloadUrl);
          });
          
          // Save to Firestore
          await _profileService.addPhoto(userId, downloadUrl);
          
          Get.snackbar(
            'Success',
            'Photo uploaded successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to upload photo',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.back(); // Close loading dialog if open
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _removePhoto(int index) async {
    if (index < 0 || index >= _photos.length) return;
    
    try {
      final photoUrl = _photos[index];
      final userId = authController.user!.uid;
      
      // Remove from local state
      setState(() {
        _photos.removeAt(index);
      });
      
      // Remove from Firestore
      await _profileService.removePhoto(userId, photoUrl);
      
      // Delete from Firebase Storage if it's a URL (not local path)
      if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
        await _storageService.deleteImage(photoUrl);
      }
      
      Get.snackbar(
        'Success',
        'Photo removed successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove photo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _addInterest() {
    if (_interestController.text.trim().isNotEmpty) {
      setState(() {
        _interests.add(_interestController.text.trim());
        _interestController.clear();
      });
    }
  }

  void _removeInterest(int index) {
    setState(() {
      _interests.removeAt(index);
    });
  }

  void _addCommunity() {
    if (_communityController.text.trim().isNotEmpty) {
      setState(() {
        _communities.add(_communityController.text.trim());
        _communityController.clear();
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      final updatedProfile = _profile!.copyWith(
        bio: _bioController.text.trim(),
        interests: _interests,
        communities: _communities,
        values: _values,
        photos: _photos,
      );
      
      final success = await _profileService.updateProfile(updatedProfile);
      
      if (success) {
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await _loadData();
      } else {
        Get.snackbar(
          'Error',
          'Failed to update profile',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Color(0xFF6C9EFF), Color(0xFF9B59B6)],
          ).createShader(bounds),
          child: Text(
            "My Profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Profile Strength
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Text(
                  "Profile strength: ",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFF9B59B6)],
                  ).createShader(bounds),
                  child: Text(
                    "${_calculateProfileStrength()}% completed",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primaryColor,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 3,
                color: AppTheme.primaryColor,
              ),
            ),
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Edit profile"),
              Tab(text: "Preview profile"),
            ],
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEditProfileTab(),
                _buildPreviewProfileTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: "Photos and videos",
            subtitle: "Pick some that show the true you.",
            child: _buildPhotosGrid(),
          ),
          SizedBox(height: 32),
          _buildSection(
            title: "Interest",
            subtitle: "Get specific about the things you love.",
            child: Column(
              children: [
                _buildAddField(
                  controller: _interestController,
                  hint: "Add your favorite interest",
                  onAdd: _addInterest,
                ),
                SizedBox(height: 12),
                _buildTags(_interests, _removeInterest, [
                  Icons.favorite,
                  Icons.local_cafe,
                  Icons.chat_bubble_outline,
                  Icons.pets,
                ]),
              ],
            ),
          ),
          SizedBox(height: 32),
          _buildSection(
            title: "My communities",
            subtitle: "Add more than 3 causes close to your heart.",
            child: _buildAddField(
              controller: _communityController,
              hint: "Add your causes and communities",
              onAdd: _addCommunity,
            ),
          ),
          SizedBox(height: 32),
          _buildSection(
            title: "Personal Value",
            subtitle: "Choose more than 3 qualities you value in a person.",
            child: Row(
              children: [
                Expanded(child: _buildValueTag("Humor")),
                SizedBox(width: 8),
                Expanded(child: _buildValueTag("Kindness")),
                SizedBox(width: 8),
                Expanded(child: _buildValueTag("Ambition")),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
          SizedBox(height: 32),
          _buildSection(
            title: "Bio",
            subtitle: "Write a fun and punchy intro.",
            child: TextField(
              controller: _bioController,
              maxLines: 4,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "A little bit about you...",
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
          _buildSection(
            title: "About you",
            child: _buildAboutYouList([
              {'icon': Icons.work, 'label': 'Work'},
              {'icon': Icons.wc, 'label': 'Gender'},
              {'icon': Icons.location_on, 'label': 'Location'},
              {'icon': Icons.home, 'label': 'Hometown'},
            ]),
          ),
          SizedBox(height: 32),
          _buildSection(
            title: "More about you",
            subtitle: "Cover the things most people are curious about.",
            child: _buildAboutYouList([
              {'icon': Icons.straighten, 'label': 'Height'},
              {'icon': Icons.fitness_center, 'label': 'Exercise'},
              {'icon': Icons.school, 'label': 'Educational level'},
              {'icon': Icons.wine_bar, 'label': 'Drinking'},
              {'icon': Icons.smoking_rooms, 'label': 'Smoking'},
              {'icon': Icons.person_search, 'label': 'Looking for'},
              {'icon': Icons.family_restroom, 'label': 'Family plans'},
              {'icon': Icons.star, 'label': 'Star sign'},
              {'icon': Icons.church, 'label': 'Religion'},
            ]),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 16),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text("Save Profile", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, String? subtitle, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [AppTheme.primaryColor, Color(0xFF9B59B6)],
          ).createShader(bounds),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
        SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildPhotosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        if (index < _photos.length) {
          final photoUrl = _photos[index];
          final isNetworkImage = photoUrl.startsWith('http://') || photoUrl.startsWith('https://');
          
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: isNetworkImage
                      ? DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: FileImage(File(photoUrl)),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removePhoto(index),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          );
        } else {
          return GestureDetector(
            onTap: _pickImage,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 32),
            ),
          );
        }
      },
    );
  }

  Widget _buildAddField({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onAdd,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(Icons.add, color: Colors.white),
          onPressed: onAdd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      onSubmitted: (_) => onAdd(),
    );
  }

  Widget _buildTags(List<String> tags, Function(int) onRemove, List<IconData> icons) {
    if (tags.isEmpty) return SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(tags.length, (index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (index < icons.length)
                Icon(icons[index], color: AppTheme.primaryColor, size: 16),
              SizedBox(width: 4),
              Text(tags[index], style: TextStyle(color: Colors.white, fontSize: 14)),
              SizedBox(width: 4),
              GestureDetector(
                onTap: () => onRemove(index),
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildValueTag(String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(value, style: TextStyle(color: Colors.white, fontSize: 14)),
    );
  }

  Widget _buildAboutYouList(List<Map<String, dynamic>> items) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(item['icon'], color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['label'],
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              Icon(Icons.add, color: Colors.white, size: 20),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreviewProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Card
          if (_photos.isNotEmpty)
            Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: _photos[0].startsWith('http://') || _photos[0].startsWith('https://')
                      ? NetworkImage(_photos[0]) as ImageProvider
                      : FileImage(File(_photos[0])),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF6C9EFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text("New here", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${_user?.first_name ?? ''} ${_user?.last_name ?? ''}, ${_user?.date_of_birth != null ? (DateTime.now().difference(_user!.date_of_birth!).inDays / 365).floor() : ''}",
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white, size: 16),
                            Text("Hồ Chí Minh City", style: TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                            Text("3 km away", style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 24),
          // My bio
          if (_bioController.text.isNotEmpty) ...[
            _buildPreviewSection("My bio", _bioController.text),
            SizedBox(height: 24),
          ],
          // About me
          if (_aboutMe.isNotEmpty) ...[
            _buildPreviewSection("About me", _buildAboutMeTags()),
            SizedBox(height: 24),
          ],
          // I'm looking for
          _buildPreviewSection("I'm looking for", "✨ a long-term relationship"),
          SizedBox(height: 24),
          // My interests
          if (_interests.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My interests",
                  style: TextStyle(
                    color: Color(0xFF9B59B6),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                _buildInterestTags(),
              ],
            ),
            SizedBox(height: 24),
          ],
          // Additional photos
          if (_photos.length > 1)
            ..._photos.sublist(1).map((photo) => Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: photo.startsWith('http://') || photo.startsWith('https://')
                        ? NetworkImage(photo) as ImageProvider
                        : FileImage(File(photo)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )),
          // My Convictions
          if (_communities.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My Convictions",
                  style: TextStyle(
                    color: Color(0xFF9B59B6),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                _buildCommunityTags(),
              ],
            ),
            SizedBox(height: 24),
          ],
          // Personal Values
          if (_values.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Personal Values",
                  style: TextStyle(
                    color: Color(0xFF9B59B6),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                _buildValueTags(),
              ],
            ),
            SizedBox(height: 24),
          ],
          // Swipe right if you
          _buildPreviewSection("Swipe right if you", "🚬 No smoking"),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(String title, dynamic content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF9B59B6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        content is String
            ? Text(
                content,
                style: TextStyle(color: Colors.white, fontSize: 16),
              )
            : content,
      ],
    );
  }

  String _buildAboutMeTags() {
    return "📏 180 cm • ❌ Almost never • 🎓 No college • 🍷 No • 🌿 No • ☪️ Islam • 👶 Don't want kids";
  }

  Widget _buildInterestTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _interests.map((i) {
        final icons = ["💖", "☕", "📸", "🎮"];
        final icon = icons[_interests.indexOf(i) % icons.length];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text("$icon $i", style: TextStyle(color: Colors.white, fontSize: 14)),
        );
      }).toList(),
    );
  }

  Widget _buildCommunityTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _communities.map((c) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text("✊ $c", style: TextStyle(color: Colors.white, fontSize: 14)),
        );
      }).toList(),
    );
  }

  Widget _buildValueTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _values.map((v) {
        final icons = ["💡", "💪", "😂", "🧠"];
        final icon = icons[_values.indexOf(v) % icons.length];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text("$icon $v", style: TextStyle(color: Colors.white, fontSize: 14)),
        );
      }).toList(),
    );
  }
}

