// lib/14.you_you.dart
import 'package:flutter/material.dart';
import '13.life_style.dart';
import '15.interests_hobbies.dart';

class YouYouPage extends StatefulWidget {
  const YouYouPage({super.key});

  @override
  State<YouYouPage> createState() => _YouYouPageState();
}

class _YouYouPageState extends State<YouYouPage> {
  String? loveLanguage;
  String? education;
  String? zodiac;

  final loveLanguageOptions = [
    {'label': 'Thoughtful gestures', 'icon': Icons.lightbulb},
    {'label': 'Presents', 'icon': Icons.card_giftcard},
    {'label': 'Touch', 'icon': Icons.touch_app},
    {'label': 'Compliments', 'icon': Icons.thumb_up},
    {'label': 'Time together', 'icon': Icons.access_time},
  ];

  final educationOptions = [
    {'label': 'Bachelors', 'icon': Icons.school},
    {'label': 'In College', 'icon': Icons.school_outlined},
    {'label': 'High School', 'icon': Icons.menu_book},
    {'label': 'PhD', 'icon': Icons.school_sharp},
    {'label': 'In Grad School', 'icon': Icons.menu_book_outlined},
    {'label': 'Masters', 'icon': Icons.menu_book_rounded},
    {'label': 'Trade School', 'icon': Icons.business},
  ];

  final zodiacOptions = [
    {'label': 'Capricorn', 'icon': Icons.ac_unit},
    {'label': 'Pisces', 'icon': Icons.water_drop},
    {'label': 'Aquarius', 'icon': Icons.water},
    {'label': 'Aries', 'icon': Icons.whatshot},
    {'label': 'Tarus', 'icon': Icons.terrain},
    {'label': 'Gemini', 'icon': Icons.star},
    {'label': 'Cancer', 'icon': Icons.favorite},
    {'label': 'Leo', 'icon': Icons.wb_sunny},
    {'label': 'Virgo', 'icon': Icons.local_florist},
    {'label': 'Libra', 'icon': Icons.balance},
    {'label': 'Scorpio', 'icon': Icons.bug_report},
    {'label': 'Sagittarius', 'icon': Icons.architecture},
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
                        MaterialPageRoute(
                            builder: (_) => const LifeStylePage()),
                      );
                    },
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  const Text("9/11",
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 20),

              // Progress bar 9/11
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 9 / 11,
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
                      Expanded(
                        child: Divider(color: Colors.white24, thickness: 1),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "What else makes you-you?",
                        style: TextStyle(
                            color: Color(0xFF85ACFF),
                            fontSize: 22,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Divider(color: Colors.white24, thickness: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Don’t hold back. Authenticity attracts authenticity.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildQuestion("How do you receive love?", loveLanguageOptions,
                          loveLanguage, (val) => setState(() => loveLanguage = val)),
                      const SizedBox(height: 22),
                      buildQuestion("What is your education level?", educationOptions,
                          education, (val) => setState(() => education = val)),
                      const SizedBox(height: 22),
                      buildQuestion("What is your zodiac sign?", zodiacOptions,
                          zodiac, (val) => setState(() => zodiac = val)),
                      const SizedBox(height: 30), // khoảng trống trên nút Next
                    ],
                  ),
                ),
              ),

              // Nút Next/Back
Padding(
  padding: const EdgeInsets.only(top: 20, bottom: 16), 
  child: Row(
    children: [
      TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LifeStylePage()),
          );
        },
        child: const Text(
          "Skip",
          style: TextStyle(color: Colors.white70, fontSize: 17), // giống trang 13
        ),
      ),
      const Spacer(),
      ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const InterestsHobbiesPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pinkAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), // giống trang 13
        ),
        child: const Text(
          "Next 1/4",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18), // giống trang 13
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

  // Widget xây dựng câu hỏi dạng ô vuông giống life_style
  Widget buildQuestion(String title, List<Map<String, dynamic>> options,
      String? selected, Function(String) onSelected) {
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
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 16,
          childAspectRatio: 1.6,
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
                padding: const EdgeInsets.all(5),
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
