// lib/9.sexual_orientation.dart
import 'package:flutter/material.dart';
import '8.gender_page.dart';
import '10.interested_target.dart';

class SexualOrientationPage extends StatefulWidget {
  const SexualOrientationPage({super.key});

  @override
  State<SexualOrientationPage> createState() => _SexualOrientationPageState();
}

class _SexualOrientationPageState extends State<SexualOrientationPage> {
  // Các lựa chọn (cho phép chọn nhiều nếu muốn)
  final List<String> options = [
    'Heterosexual / Straight',
    'Gay',
    'Lesbian',
    'Bisexual',
    'Pansexual',
    'Asexual',
    'Demisexual',
    'Prefer not to say',
  ];

  // giữ trạng thái chọn (multi-select). Nếu bạn muốn single-select, đổi logic accordingly.
  final Set<String> selected = {};
  bool showOnProfile = false;

  bool get canNext => selected.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          // padding chuẩn bạn yêu cầu
          padding: const EdgeInsets.fromLTRB(30, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const GenderPage()),
                      );
                    },
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  const Text("4/11", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),

              const SizedBox(height: 20),

              // progress bar 4/11
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 4 / 11,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 70),

              const Text(
                "What is your sexual orientation?",
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF85ACFF),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 40),

              // options as chips (multi-select)
              Wrap(
                runSpacing: 20,
                spacing: 20,
                children: options.map((opt) {
                  final bool active = selected.contains(opt);
                  return ChoiceChip(
                    label: Text(
                      opt,
                      style: TextStyle(
                        color: active ? Colors.white : Colors.white70,
                        fontWeight: active ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    selected: active,
                    onSelected: (v) {
                      setState(() {
                        if (v) selected.add(opt);
                        else selected.remove(opt);
                      });
                    },
                    selectedColor: Colors.pinkAccent,
                    backgroundColor: Colors.white12,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Checkbox(
                    value: showOnProfile,
                    onChanged: (v) => setState(() => showOnProfile = v ?? false),
                    activeColor: Colors.pinkAccent,
                    checkColor: Colors.white,
                  ),
                  const Expanded(
                    child: Text(
                      "Show on my profile",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Next button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canNext
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const InterestedTargetPage()),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canNext ? Colors.pinkAccent : Colors.grey[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 18,
                      color: canNext ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.bold,
                    ),
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
