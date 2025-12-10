// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:twinkle/components/chatting/chat_bubble.dart';
// import 'package:twinkle/components/chatting/my_textfield.dart';
// import 'package:twinkle/services/auth/auth_service.dart';
// import 'package:twinkle/services/chat/chat_service.dart';
// import 'package:image_picker/image_picker.dart';


// class ChatPage extends StatefulWidget {
//   final String receiverEmail;
//   final String receiverID;

//   ChatPage({
//     super.key,
//     required this.receiverEmail,
//     required this.receiverID,
//   });

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   //text controller 
//   final TextEditingController _messageController = TextEditingController();

//   //chat & auth services
//   final ChatService _chatService = ChatService();
//   final AuthService _authService = AuthService();

//   // textfield focus
//   FocusNode myFocusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();

//     myFocusNode.addListener(() {
//       if (myFocusNode.hasFocus) {
//         //delay to show up keyboard -> calculate remaining space -> scroll down
//         Future.delayed(
//           const Duration(milliseconds: 500),
//           () => scrollDown(),
//         );
//       }
//     });

//     //wait for listview to built -> scroll to bottom
//     Future.delayed(const Duration(milliseconds: 500), () => scrollDown(),);
//   }

//   @override
//   void dispose() {
//     myFocusNode.dispose();
//     _messageController.dispose();
//     super.dispose();
//   }

//   final ScrollController _scrollController = ScrollController();
//   void scrollDown() {
//     _scrollController.animateTo(
//       _scrollController.position.maxScrollExtent,
//       duration: const Duration(seconds: 1),
//       curve: Curves.fastOutSlowIn,
//     );
//   }




//   //send message
//   void sendMessage() async {
//     //if there is sth inside textfield
//     if (_messageController.text.isNotEmpty) {
//       //send the message
//       await _chatService.sendMessage(
//         widget.receiverID, 
//         _messageController.text
//       );

//       //clear text controller
//       _messageController.clear();
//     }
//     scrollDown();
//   }

//   @override //UI
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.receiverEmail)),
//       body: Column(
//         children: [
//           //display all messages
//           Expanded(
//             child: _buildMessageList(),
//           ),

//           //user input
//           _buildUserInput(),
  
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageList() {
//     String senderID = _authService.getCurrentUser()!.uid;
//     return StreamBuilder(
//       stream: _chatService.getMessages(senderID, widget.receiverID), 
//       builder: (context, snapshot) {
//         //error
//         if (snapshot.hasError) {
//           return Text("Error");
//         }
        
//         // loading..
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Text("Loading..");
//         }

//         //return list view 
//         return ListView(
//           controller: _scrollController,
//           children: 
//             snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
//         );

//       },
//     );
//   }

//   Widget _buildMessageItem(DocumentSnapshot doc) {
//     Map<String,dynamic> data = doc.data() as Map<String, dynamic>;
    
//     //is current user
//     bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

//     //align text field
//     var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;


//     return Container(
//       alignment: alignment,
//       child: Column(
//         crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           ChatBubble(
//             isCurrentUser: isCurrentUser, 
//             message: data['message'],
//           )
//         ],
//       ),
//       );
//   }

//   //buid message input
//   Widget _buildUserInput() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 25.0),
//       child: Row(
//         children: [
          
//           //textfield
//           Expanded(
//             child: MyTextfield(
//               controller: _messageController,
//               hintText: "Type something...", 
//               obscureText: false, 
//               focusNode: myFocusNode,
//             ),
//           ),
      
//           //send button
//           Container(
//             decoration: BoxDecoration(
//               color: const Color.fromARGB(255, 227, 160, 239),
//               shape: BoxShape.circle,
              
//             ),

//             child: IconButton(
//               onPressed: sendMessage, 
//               icon: const Icon(
//                 Icons.arrow_upward,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }