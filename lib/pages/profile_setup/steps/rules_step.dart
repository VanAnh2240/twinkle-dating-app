import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/profile_setup_controller.dart';
import 'package:twinkle/themes/theme.dart';

class RulesStep extends StatelessWidget {
  RulesStep({super.key});

  final ProfileSetupController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color.fromARGB(255, 232, 131, 255), AppTheme.primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Welcome to Twinkle',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                  textAlign: TextAlign.start,
                ),

                const SizedBox(height: 8),

                Text(
                  'Please follow these house rules',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500
                  ),
                  textAlign: TextAlign.start,
                ),

                const SizedBox(height: 40),

                // Rules
                _buildRule(
                  'Be yourself',
                  'Make sure your photos, age, and bio are true to who you are.',
                ),
                const SizedBox(height: 12),
                _buildRule(
                  'Stay safe',
                  'Don\'t be too quick to give out personal information.',
                ),
                const SizedBox(height: 12),
                _buildRule(
                  'Play it cool',
                  'Respect others and treat them as you would like to be treated.',
                ),
                const SizedBox(height: 12),
                _buildRule(
                  'Be proactive',
                  'Always report bad behavior.',
                ),
              ],
            ),
          ),
        ),

        // Next Button 
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: controller.nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.quaternaryColor,
                disabledBackgroundColor: Colors.white10,
                padding: EdgeInsets.symmetric(horizontal: 16),
                elevation: 4,
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
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRule(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7B9BFF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}