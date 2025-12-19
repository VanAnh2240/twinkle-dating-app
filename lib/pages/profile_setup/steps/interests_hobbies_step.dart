import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/profile_setup_controller.dart';
import 'package:twinkle/themes/theme.dart';

// ==================== INTERESTS & HOBBIES STEP ====================
class InterestsHobbiesStep extends StatelessWidget {
  InterestsHobbiesStep({super.key});

  final ProfileSetupController controller = Get.find();

  final Map<String, List<String>> interestCategories = {
    'Music & Entertainment': [
      'Live music',
      'Singing / Karaoke',
      'Board games',
      'Video games',
      'Trivia',
      'Dancing',
      'Concerts',
    ],
    'Tech & Gaming': [
      'Vlogging',
      'Blogging',
      'Podcasts',
      'Instagram',
      'YouTube',
      'Photography',
      'Language Learning',
      'Public speaking',
    ],
    'Health & Wellness': [
      'Running',
      'Walking',
      'Swimming',
      'Yoga',
      'Cycling',
      'Meditation / Mindfulness',
      'Mental health',
    ],
    'Travel & Adventure': [
      'Road trips',
      'City exploring',
      'Beach trips',
      'Hiking',
      'Camping',
    ],
    'Food & Drink': [
      'Cooking / Baking',
      'Eating out / restaurants',
      'Wine tasting',
      'Craft beer',
      'Coffee',
    ],
    'Sports & Outdoor Activities': [
      'Beach / Football',
      'Basketball',
      'Swimming',
      'Tennis',
      'Surfing',
      'Skiing',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Text(
                  'What are you into?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Now, let everyone know.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 32),

                ...interestCategories.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: AppTheme.quaternaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: entry.value.map((interest) {
                            return Obx(() {
                              final isSelected = controller.interests.contains(interest);
                              return InkWell(
                                onTap: () => controller.toggleInterest(interest),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.quaternaryColor.withOpacity(0.2)
                                        : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.quaternaryColor
                                          : Colors.white24,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    interest,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            });
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),

        // Next Button with counter
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.canProceed ? controller.nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.canProceed
                    ? AppTheme.quaternaryColor
                    : Colors.grey[800],
                padding: EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  color: controller.canProceed ? Colors.white : Colors.white38,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )),
        ),
      ],
    );
  }
}