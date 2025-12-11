import 'package:flutter/material.dart';
import 'package:twinkle/services/auth_service.dart';
import 'package:twinkle/pages/setting_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // logout
  void logout() {
    // get auth service
    final auth = AuthService();
    auth.signOut();
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          //logo
          DrawerHeader(
            child: Center(
              child: Icon(
                Icons.message,
                color: Theme.of(context).colorScheme.primary,
                size: 40
              ),
              
            ),
          ),

          //home list title
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: ListTile(
              title : const Text("HOME"),
              leading: const Icon(Icons.home),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          
          //setting list title
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: ListTile(
              title : const Text("SETTING"),
              leading: const Icon(Icons.settings),
              onTap: () {
                //pop drawer
                Navigator.pop(context);

                //navigate to setting page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingPage()
                    )
                );
              },
            ),
          ),

          //logout list title 
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: ListTile(
              title : Text("LOGOUT"),
              leading: Icon(Icons.logout),
              onTap: logout,
            ),
          )

        ],
      ),
    );
  }
}