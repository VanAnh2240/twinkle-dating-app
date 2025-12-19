
// ==================== BIO STEP ====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/profile_setup_controller.dart';
import 'package:twinkle/themes/theme.dart';

class BioStep extends StatelessWidget {
  BioStep({super.key});

  final ProfileSetupController controller = Get.find();
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (controller.bio.value.isNotEmpty) {
      textController.text = controller.bio.value;
    }

    return Column(
      children: [
        SingleChildScrollView(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Text(
                  'Tell us about yourself',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Write a bio that shows your personality',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller: textController,
                  maxLines: 8,
                  maxLength: 500,
                  onChanged: (value) => controller.bio.value = value,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Write something interesting about yourself...',
                    hintStyle: TextStyle(color: Colors.white38),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppTheme.quaternaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    counterStyle: TextStyle(color: Colors.white54),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'A good bio helps others know you better',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
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

