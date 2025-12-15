// lib/13.life_style.dart
import 'package:flutter/material.dart';
import '12.distance.dart';
import '14.you_you.dart';

class LifeStylePage extends StatefulWidget {
  const LifeStylePage({super.key});

  @override
  State<LifeStylePage> createState() => _LifeStylePageState();
}

class _LifeStylePageState extends State<LifeStylePage> {
  String? drink;
  String? smoke;
  String? workout;
  String? pets;

  final drinkOptions = [
    {'label': 'Not for me', 'icon': Icons.block},
    {'label': 'Sober', 'icon': Icons.emoji_people},
    {'label': 'Most nights', 'icon': Icons.nightlife},
    {'label': 'Sober curious', 'icon': Icons.remove_circle_outline},
    {'label': 'On special occasions', 'icon': Icons.event},
    {'label': 'Socially on weekends', 'icon': Icons.group},
  ];

  final smokeOptions = [
    {'label': 'Social smoker', 'icon': Icons.group},
    {'label': 'Smoker when drinking', 'icon': Icons.local_bar},
    {'label': 'Non-smoker', 'icon': Icons.smoke_free},
    {'label': 'Smoker', 'icon': Icons.smoking_rooms},
    {'label': 'Trying to quit', 'icon': Icons.health_and_safety},
  ];

  final workoutOptions = [
    {'label': 'Everyday', 'icon': Icons.fitness_center},
    {'label': 'Often', 'icon': Icons.access_time},
    {'label': 'Sometimes', 'icon': Icons.hourglass_bottom},
    {'label': 'Never', 'icon': Icons.bedtime},
  ];

  final petsOptions = [
    {'label': 'Dog', 'icon': Icons.pets},
    {'label': 'Cat', 'icon': Icons.pets},
    {'label': 'Reptile', 'icon': Icons.eco},
    {'label': 'Amphibian', 'icon': Icons.water},
    {'label': 'Bird', 'icon': Icons.flight},
    {'label': 'Fish', 'icon': Icons.pool},
    {'label': 'Don’t have but love', 'icon': Icons.favorite},
    {'label': 'Other', 'icon': Icons.help_outline},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              // Top bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const DistancePage()),
                      );
                    },
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  const Text("8/11", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 20),

              // Progress bar
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 8 / 11,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Title + horizontal line
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                      const SizedBox(width: 8),
                      const Text(
                        "Let’s talk lifestyle habits!",
                        style: TextStyle(
                          color: Color(0xFF85ACFF),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Do their habits match yours?",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildQuestionGrid("How often do you drink?", drinkOptions, drink,
                          (val) => setState(() => drink = val)),
                      const SizedBox(height: 22),
                      buildQuestionGrid("How often do you smoke?", smokeOptions, smoke,
                          (val) => setState(() => smoke = val)),
                      const SizedBox(height: 22),
                      buildQuestionGrid("Do you workout?", workoutOptions, workout,
                          (val) => setState(() => workout = val)),
                      const SizedBox(height: 22),
                      buildQuestionGrid("Do you have any pets?", petsOptions, pets,
                          (val) => setState(() => pets = val)),
                      const SizedBox(height: 30), // khoảng cách an toàn với nút Next
                    ],
                  ),
                ),
              ),

              // Nút Next/Skip với khoảng cách phía trên và dưới đáy
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 16), // khoảng cách trên và dưới
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const YouYouPage()),
                        );
                      },
                      child: const Text(
                        "Skip",
                        style: TextStyle(color: Colors.white70, fontSize: 17),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const YouYouPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Text(
                        "Next 0/4",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ------------------ WIDGET QUESTION GRID ------------------
  Widget buildQuestionGrid(
      String title, List<Map<String, dynamic>> options, String? selected, Function(String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, color: Colors.pinkAccent, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16, // khoảng cách lớn giữa các ô
          crossAxisSpacing: 16,
          childAspectRatio: 1.5, // ô nhỏ hơn, chữ dài xuống dòng
          children: options.map((opt) {
            final bool active = selected == opt['label'];
            return GestureDetector(
              onTap: () => onSelected(opt['label']),
              child: Container(
                decoration: BoxDecoration(
                  color: active ? Colors.pinkAccent : Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: active ? Colors.pinkAccent : Colors.white24,
                      width: 1.5),
                ),
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(opt['icon'], color: active ? Colors.white : Colors.white70),
                    const SizedBox(height: 4),
                    Text(
                      opt['label'],
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                          color: active ? Colors.white : Colors.white70,
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
