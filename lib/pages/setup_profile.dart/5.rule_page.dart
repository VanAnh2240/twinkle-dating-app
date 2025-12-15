import 'package:flutter/material.dart';
import '7.name_page.dart';


class RulePage extends StatelessWidget {
  const RulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // BUTTON CỐ ĐỊNH
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
        color: Colors.black,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const NamePage()),
              );
            },

            child: const Text(
              "I AGREE",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),

      // NỘI DUNG CUỘN
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 40, 24, 120),
          // 120 = chừa chỗ cho button + khoảng cách, không dư scroll
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Image.asset("assets/images/rule.png)",
                  height: 120,
                ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Welcome to Twinkle",
                style: TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Please follow these house rules",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 32),

              _ruleItem(
                title: "Be yourself",
                titleColor: Color(0xFF85ACFF),
                desc:
                    "Make sure your photos, age, and bio are true to who you are.",
              ),
              const SizedBox(height: 28),

              _ruleItem(
                title: "Stay safe",
                titleColor: Color(0xFF85ACFF),
                desc:
                    "Don’t be too quick to give out personal information.",
              ),
              const SizedBox(height: 28),

              _ruleItem(
                title: "Play it cool",
                titleColor: Color(0xFF85ACFF),
                desc:
                    "Respect others and treat them as you would like to be treated.",
              ),
              const SizedBox(height: 28),

              _ruleItem(
                title: "Be proactive",
                titleColor: Color(0xFF85ACFF),
                desc: "Always report bad behavior.",
              ),
              const SizedBox(height: 28),

              _ruleItem(
                title: "No ghosting",
                titleColor: Color(0xFF85ACFF),
                desc: "If you're not interested, just say so politely.",
              ),
              const SizedBox(height: 28),

              _ruleItem(
                title: "Have fun",
                titleColor: Color(0xFF85ACFF),
                desc: "The goal is to connect and enjoy the moment.",
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _ruleItem({
  required String title,
  required Color titleColor,
  required String desc,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 22,
          height: 1.2,
          color: titleColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        desc,
        style: const TextStyle(
          fontSize: 16,
          height: 1.4,
          color: Colors.white,
        ),
      ),
    ],
  );
}
