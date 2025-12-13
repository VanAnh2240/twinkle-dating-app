// import 'package:get/get.dart';
// import 'package:twinkle/controllers/auth_controller.dart';
// import 'package:twinkle/models/messages_model.dart';
// import 'package:twinkle/models/users_model.dart';
// import 'package:twinkle/services/chatroom_service.dart';
// import 'package:twinkle/services/match_service.dart';
// import 'package:twinkle/services/messeage_service.dart';

// class MessageController extends GetxController {
//   final MatchService _match = MatchService();
//   final ChatRoomsService _chatrooms = ChatRoomsService();
//   final MessageService _message = MessageService();
 
//   final RxList<String> chatRooms = <String>[].obs;
//   final RxBool isLoading = false.obs;

//   final RxList<UsersModel> potentialMatches = <UsersModel>[].obs;

//   // Send message
//   Future<void> sendMessage(String chatroomId, String receiverId, String text) async {
//     await _message.sendMessage(chatroomId, receiverId, text);
//   }

//   // Get messages
//   Stream<List<MessagesModel>> getMessages(String chatroomId) {
//     return _message.getMessages(chatroomId);
//   }
// }
