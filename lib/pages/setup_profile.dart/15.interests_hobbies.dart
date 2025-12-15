// lib/15.interests_hobbies.dart
import 'package:flutter/material.dart';
import '14.you_you.dart';
import '16.picture.dart';

class InterestsHobbiesPage extends StatefulWidget {
  const InterestsHobbiesPage({super.key});

  @override
  State<InterestsHobbiesPage> createState() => _InterestsHobbiesPageState();
}

class _InterestsHobbiesPageState extends State<InterestsHobbiesPage> {
  // Selected value cho mỗi câu hỏi
  String? music;
  String? tech;
  String? health;
  String? travel;
  String? food;
  String? learning;
  String? animals;
  String? sports;

  // ------------------ OPTIONS WITH ICONS ------------------
  final musicOptions = [
    {'label': 'Live music / Concerts', 'icon': Icons.music_note},
    {'label': 'Singing / Karaoke', 'icon': Icons.mic},
    {'label': 'Playing instruments', 'icon': Icons.queue_music},
    {'label': 'Music festivals', 'icon': Icons.event},
    {'label': 'DJ / Producing', 'icon': Icons.headphones},
    {'label': 'Podcast', 'icon': Icons.podcasts},
    {'label': 'Binge - watching', 'icon': Icons.tv},
    {'label': 'Movies/ film', 'icon': Icons.movie},
    {'label': 'Theater / Musicals', 'icon': Icons.theater_comedy},
  ];

  final techOptions = [
    {'label': 'Video games', 'icon': Icons.sports_esports},
    {'label': 'Mobile games', 'icon': Icons.phone_android},
    {'label': 'Board games', 'icon': Icons.videogame_asset},
    {'label': 'PC building', 'icon': Icons.desktop_windows},
    {'label': 'Coding', 'icon': Icons.code},
    {'label': 'Crypto', 'icon': Icons.currency_bitcoin},
  ];

  final healthOptions = [
    {'label': 'Fitness / Gym', 'icon': Icons.fitness_center},
    {'label': 'Running / Jogging', 'icon': Icons.directions_run},
    {'label': 'Yoga / Meditation', 'icon': Icons.self_improvement},
    {'label': 'Hiking', 'icon': Icons.terrain},
    {'label': 'Healthy eating / Nutrition', 'icon': Icons.local_dining},
    {'label': 'Mental health', 'icon': Icons.psychology},
  ];

  final travelOptions = [
    {'label': 'Road trips', 'icon': Icons.directions_car},
    {'label': 'City exploring', 'icon': Icons.location_city},
    {'label': 'Beach lover', 'icon': Icons.beach_access},
    {'label': 'Nature walks', 'icon': Icons.park},
    {'label': 'Camping', 'icon': Icons.nature},
  ];

  final foodOptions = [
    {'label': 'Cooking / Baking', 'icon': Icons.kitchen},
    {'label': 'Trying new restaurants', 'icon': Icons.restaurant},
    {'label': 'Coffee lover', 'icon': Icons.coffee},
    {'label': 'Wine tasting', 'icon': Icons.wine_bar},
    {'label': 'Craft beer', 'icon': Icons.local_drink},
    {'label': 'Foodie adventures', 'icon': Icons.fastfood},
  ];

  final learningOptions = [
    {'label': 'Reading', 'icon': Icons.menu_book},
    {'label': 'Writing / Journaling', 'icon': Icons.edit},
    {'label': 'Language Learning', 'icon': Icons.language},
    {'label': 'Public speaking', 'icon': Icons.campaign},
    {'label': 'Self-development', 'icon': Icons.school},
    {'label': 'History / Documentaries', 'icon': Icons.history_edu},
  ];

  final animalsOptions = [
    {'label': 'Dog lover', 'icon': Icons.pets},
    {'label': 'Cat person', 'icon': Icons.pets},
    {'label': 'Animal rescue', 'icon': Icons.volunteer_activism},
    {'label': 'Birdwatching', 'icon': Icons.filter_hdr},
    {'label': 'Gardening', 'icon': Icons.grass},
  ];

  final sportsOptions = [
    {'label': 'Soccer / Football', 'icon': Icons.sports_soccer},
    {'label': 'Basketball', 'icon': Icons.sports_basketball},
    {'label': 'Swimming', 'icon': Icons.pool},
    {'label': 'Cycling', 'icon': Icons.pedal_bike},
    {'label': 'Surfing', 'icon': Icons.surfing},
    {'label': 'Climbing', 'icon': Icons.terrain},
    {'label': 'Martial arts', 'icon': Icons.sports_martial_arts},
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
                        MaterialPageRoute(builder: (_) => const YouYouPage()),
                      );
                    },
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  const Text("10/11",
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
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
                  widthFactor: 10 / 11,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Title
              Column(
                children: const [
                  Text(
                    "What are you into?",
                    style: TextStyle(
                        color: Color(0xFF85ACFF),
                        fontSize: 22,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "You like what you like. Now, let everyone know.",
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
                      buildQuestionGrid("Music & Entertainment", musicOptions, music,
                          (val) => setState(() => music = val)),
                      const SizedBox(height: 22),
                      buildQuestionGrid("Tech & Gaming", techOptions, tech,
                          (val) => setState(() => tech = val)),
                      const SizedBox(height: 22),
                      buildQuestionGrid("Health & Wellness", healthOptions, health,
                          (val) => setState(() => health = val)),
                      const SizedBox(height: 22),
                      buildQuestionGrid("Travel & Adventure", travelOptions, travel,
                          (val) => setState(() => travel = val)),
                      const SizedBox(height: 22),
                      buildQuestionGrid("Food & Drink", foodOptions, food,
                          (val) => setState(() => food = val)),
                      const SizedBox(height: 22),
                      buildQuestionGrid("Learning & Personal Growth", learningOptions, learning,
                          (val) => setState(() => learning = val)),
                      const SizedBox(height: 22),
                      buildQuestionGrid("Animals & Nature", animalsOptions, animals,
                          (val) => setState(() => animals = val)),
                      const SizedBox(height: 22),
                      buildQuestionGrid("Sports & Outdoor Activities", sportsOptions, sports,
                          (val) => setState(() => sports = val)),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Nút Back/Next
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 16),
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
                        "Back",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PicturePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Text(
                        "Next 3/4",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
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

  // ------------------ WIDGET GRID CHỌN OPTION ------------------
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
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
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
