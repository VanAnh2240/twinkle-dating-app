import 'dart:io';

import 'package:flutter/material.dart';
import '15.interests_hobbies.dart';
import 'package:image_picker/image_picker.dart';

class PicturePage extends StatefulWidget {
  const PicturePage({super.key});

  @override
  State<PicturePage> createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage> {
  final ImagePicker _picker = ImagePicker();
  List<File> images = [];

  Future<void> pickImage(int index) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (images.length > index) {
          images[index] = File(pickedFile.path);
        } else {
          images.add(File(pickedFile.path));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const InterestsHobbiesPage()),
                      );
                    },
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  const Text("11/11",
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
                  widthFactor: 11 / 11,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Add your recent pics",
                style: TextStyle(
                    color: Color(0xFF85ACFF),
                    fontSize: 22,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                "Upload at least one picture to complete your profile.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 30),

              // Grid 6 ô
              Expanded(
                child: GridView.builder(
                  itemCount: 6,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => pickImage(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24, width: 1.5),
                        ),
                        child: images.length > index
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(images[index],
                                    fit: BoxFit.cover),
                              )
                            : const Center(
                                child: Icon(Icons.add,
                                    color: Colors.white70, size: 40),
                              ),
                      ),
                    );
                  },
                ),
              ),

              // Nút Next/Done
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 16),
                child: Row(
                  children: [
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // Logic khi nhấn Next/Done
                        if (images.isNotEmpty) {
                          // Done -> hoàn tất profile
                          Navigator.pop(context); // ví dụ về home
                        } else {
                          // Next -> chưa thêm ảnh, chuyển trang khác nếu cần
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                      child: Text(
                        images.isNotEmpty ? "Done" : "Next",
                        style: const TextStyle(
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
}
