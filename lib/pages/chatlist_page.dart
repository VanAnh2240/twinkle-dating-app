// import 'package:flutter/material.dart';
// import 'package:twinkle/components/my_drawer.dart';
// import 'package:twinkle/components/user_tile.dart';
// import 'package:twinkle/pages/chat_page.dart';
// import 'package:twinkle/services/auth/auth_service.dart';
// import 'package:twinkle/services/chat/chat_service.dart';


// class ChatListPage extends StatelessWidget {
//   ChatListPage({super.key});

//   // chat & auth service
//   final ChatService _chatService = ChatService();
//   final AuthService _authService = AuthService();


//   void logout() {
//     //get auth service
//     final auth = AuthService();
//     auth.signOut();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           "ChatListPage",
//         ),
//       ),

//       drawer: const MyDrawer(),

//       body: _buildUserList(),
//     );
//   }

//   // build a list of users exccept for the current logged in user
//   Widget _buildUserList() {
//       return StreamBuilder(
//         stream: _chatService.getUsersStream(), 
//         builder: (context, snapshot) {
//           //error
//           if (snapshot.hasError) {
//             return const Text("Error"); 
//           }
          
//           //loading
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Text ("Loading...");
//           }

//           //return list view
//           return ListView(
//             children: snapshot.data!
//             .map<Widget>((userData) => _buildUserListItem(userData, context)).toList(),
//           );
//         },
//       );
//   }

//   //build invidual list tile for user
//   Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) 
//   {
//     final currentUserEmail = _authService.getCurrentUser()!.email;

//     // displact all users except current one
//     if (userData['email'] != currentUserEmail) {  
//       return UserTile(
//         text: userData['email'],
//         onTap: () {
//           //tapped on a user => Go chat page
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ChatPage(
//                 receiverEmail: userData['email'],
//                 receiverID: userData['uid'],
//               ),
//             ),
//           );
//         }
//       );
//     }
//     else {
//       return Container();
//     }
//   }
// }