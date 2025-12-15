import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/profile_controller.dart';

class ProfileSetupPage extends StatelessWidget {
  ProfileSetupPage({Key? key}) : super(key: key);

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profile'),
        actions: [
          Obx(() => controller.isSaving.value
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => controller.saveProfile(),
                  tooltip: 'Save Profile',
                ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos Section
              _buildPhotosSection(),
              const SizedBox(height: 24),

              // Location
              _buildLocationField(),
              const SizedBox(height: 16),

              // Bio
              _buildBioField(),
              const SizedBox(height: 24),

              // About Me
              _buildAboutMeSection(),
              const SizedBox(height: 24),

              // Interests
              _buildInterestsSection(),
              const SizedBox(height: 24),

              // Communities
              _buildCommunitiesSection(),
              const SizedBox(height: 24),

              // Values
              _buildValuesSection(),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Photos (Max 6)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Obx(() => Text(
                  '${controller.photos.length}/6',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                )),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'First photo will be your profile picture',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Obx(() => controller.isUploadingPhoto.value
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: controller.photos.length + 
                    (controller.photos.length < 6 ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.photos.length) {
                    // Add photo button
                    return GestureDetector(
                      onTap: () => controller.pickAndUploadImage(),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_photo_alternate, 
                                size: 40, color: Colors.grey),
                            SizedBox(height: 4),
                            Text('Add Photo', 
                                style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }

                  // Photo item
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(controller.photos[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Badge for first photo
                      if (index == 0)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // Delete button
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _confirmDeletePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Obx(() => TextField(
              decoration: InputDecoration(
                hintText: 'e.g., New York, USA',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
              onChanged: (value) => controller.location.value = value,
              controller: TextEditingController(text: controller.location.value)
                ..selection = TextSelection.collapsed(
                    offset: controller.location.value.length),
            )),
      ],
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About You *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Obx(() => TextField(
              decoration: InputDecoration(
                hintText: 'Write a few lines about yourself...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 4,
              maxLength: 500,
              onChanged: (value) => controller.bio.value = value,
              controller: TextEditingController(text: controller.bio.value)
                ..selection = TextSelection.collapsed(
                    offset: controller.bio.value.length),
            )),
      ],
    );
  }

  Widget _buildAboutMeSection() {
    final options = [
      'Music',
      'Hiking',
      'Travel',
      'Cooking',
      'Reading',
      'Sports',
      'Photography',
      'Art'
    ];

    return _buildChipSection(
      title: 'About Me',
      subtitle: 'Choose what describes you',
      options: options,
      selectedItems: controller.aboutMe,
      onToggle: controller.toggleAboutMe,
      color: Colors.pink,
    );
  }

  Widget _buildInterestsSection() {
    final options = [
      'Guitar',
      'Painting',
      'Photography',
      'Dancing',
      'Gaming',
      'Yoga',
      'Swimming',
      'Cycling'
    ];

    return _buildChipSection(
      title: 'Interests',
      subtitle: 'Your hobbies and passions',
      options: options,
      selectedItems: controller.interests,
      onToggle: controller.toggleInterest,
      color: Colors.blue,
    );
  }

  Widget _buildCommunitiesSection() {
    final options = [
      'Travelers',
      'Music Lovers',
      'Foodies',
      'Fitness',
      'Artists',
      'Book Clubs',
      'Tech Enthusiasts'
    ];

    return _buildChipSection(
      title: 'Communities',
      subtitle: 'Groups you belong to',
      options: options,
      selectedItems: controller.communities,
      onToggle: controller.toggleCommunity,
      color: Colors.green,
    );
  }

  Widget _buildValuesSection() {
    final options = [
      'Respect',
      'Honesty',
      'Loyalty',
      'Kindness',
      'Humor',
      'Ambition',
      'Creativity'
    ];

    return _buildChipSection(
      title: 'Values',
      subtitle: 'What matters most to you',
      options: options,
      selectedItems: controller.values,
      onToggle: controller.toggleValue,
      color: Colors.purple,
    );
  }

  Widget _buildChipSection({
    required String title,
    required String subtitle,
    required List<String> options,
    required RxList<String> selectedItems,
    required Function(String) onToggle,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = selectedItems.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (_) => onToggle(option),
                  selectedColor: color.withOpacity(0.2),
                  checkmarkColor: Colors.grey.shade700,
                );
              }).toList(),
            )),
      ],
    );
  }

  void _confirmDeletePhoto(int index) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removePhoto(index);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}