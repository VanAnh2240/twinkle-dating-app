import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/models/messages_model.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/services/chat_service.dart';
import 'package:twinkle/services/match_service.dart';

class MessageController extends GetxController {
  final MatchService _matchService = MatchService();
  final ChatService _chatService = ChatService();

  final RxList<String> chatRooms = <String>[].obs;
  final RxBool isLoading = false.obs;

  final RxList<UsersModel> potentialMatches = <UsersModel>[].obs;

  void listenChatRooms() {
    String currentID = Get.find<AuthController>().user!.uid;
    chatRooms.bindStream(_matchService.getUserChatRooms(currentID));
  }

  Future<void> unMatch(String other) async {
    String currentID = Get.find<AuthController>().user!.uid;
    await _matchService.unMatch(currentID, other);
  }

  Future<void> sendMessage(String chatroomId, String receiverId, String text) async {
    await _chatService.sendMessage(chatroomId, receiverId, text);
  }

  Stream<List<MessagesModel>> getMessages(String chatroomId) {
    return _chatService.getMessages(chatroomId);
  }
}
