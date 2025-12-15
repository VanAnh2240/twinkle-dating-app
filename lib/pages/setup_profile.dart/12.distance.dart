// lib/12.distance_page.dart
import 'package:flutter/material.dart';
import '11.looking_for.dart';
import '13.life_style.dart';

class DistancePage extends StatefulWidget {
  const DistancePage({super.key});

  @override
  State<DistancePage> createState() => _DistancePageState();
}

class _DistancePageState extends State<DistancePage> {
  double sliderValue = 10; // Giá trị km hiện tại
  double maxSlider = 100; // Giá trị max của slider

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ---------------- TOP BAR ----------------
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LookingForPage()),
                      );
                    },
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  const Text(
                    "7/11",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------------- PROGRESS BAR 7/11 ----------------
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 7 / 11,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 70),

              // ---------------- TITLE ----------------
              const Text(
                "Your distance preference?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF85ACFF),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Use the slide to set the maximum distance you want your potential matches to be located",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 50),

              // ---------------- SLIDER BOX WITH LABEL ----------------
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(31, 0, 0, 0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12), // khoảng trống cho chữ lấn lên
                        Text(
                          "${sliderValue.toStringAsFixed(0)} km",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        const SizedBox(height: 16),
                        Slider(
                          value: sliderValue,
                          min: 1,
                          max: maxSlider,
                          divisions: (maxSlider - 1).toInt(),
                          activeColor: Colors.pinkAccent,
                          inactiveColor: Colors.white24,
                          label: "${sliderValue.toStringAsFixed(0)} km",
                          onChanged: (value) {
                            setState(() => sliderValue = value);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Label trên cạnh viền
                  Positioned(
                    top: -12, // lấn ra ngoài container
                    left: 40, // căn lề trái
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 2),
                      color: Colors.black, // nền giống background
                      child: const Text(
                        "Between 1 and 100",
                        style:
                            TextStyle(color: Colors.white70, fontSize: 17),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "You can change it later in Settings",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const Spacer(),

              // ---------------- NEXT BUTTON ----------------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LifeStylePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
