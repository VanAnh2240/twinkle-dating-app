import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Setting"),
      ),

      // body: Container(
      //   decoration: BoxDecoration(
      //     color: Theme.of(context).colorScheme.secondary,
      //     borderRadius: BorderRadius.circular(10)
      //   ),
      //   margin: EdgeInsets.all(25),
      //   padding: EdgeInsets.all(15),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       // label
      //       const Text("Light Mode"),

      //       // switch toggle
      //       Obx(() {
      //         final themeController = Get.find<ThemeController>();

      //         return CupertinoSwitch(
      //           value: themeController.isDarkMode.value,
      //           onChanged: (value) {
      //             themeController.toggleTheme();
      //           },
      //         );
      //       })
      //     ],
      //   ),

      // ),
    );
  }
}