import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/profile_setup_controller.dart';
import 'package:twinkle/themes/theme.dart';

// ==================== LIFESTYLE STEP ====================
class LifestyleStep extends StatelessWidget {
  LifestyleStep({super.key});

  final ProfileSetupController controller = Get.find();

  final Map<String, List<String>> lifestyleCategories = {
    'How often do you drink?': ['Not at all', 'On special occasions', 'Socially', 'Regularly'],
    'How do you receive love?': ['Words of affirmation', 'Acts of service', 'Receiving gifts', 'Quality time', 'Physical touch'],
    'How often do you smoke?': ['Non-smoker', 'Sometimes', 'Regularly', 'Trying to quit'],
    'Do you workout?': ['Everyday', 'Often', 'Sometimes', 'Never'],
    'Do you have any pets?': ['Dog', 'Cat', 'Fish', 'Bird', 'Other', 'Don\'t have but love', 'None'],
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
                  'Let\'s talk lifestyle habits!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Do you lean healthy or wild?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 32),

                ...lifestyleCategories.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite, color: AppTheme.quaternaryColor, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: entry.value.map((option) {
                            return Obx(() {
                              final isSelected = controller.lifestyle.contains(option);
                              return InkWell(
                                onTap: () => controller.toggleLifestyle(option),
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
                                    option,
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

        // Next Button
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.quaternaryColor,
                padding: EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
