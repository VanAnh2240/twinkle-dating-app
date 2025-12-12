import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/services/match_service.dart';
import 'package:twinkle/services/user_service.dart';

class MatchController extends GetxController {
  final MatchService _matchService = MatchService();
  
  final RxList<String> chatRooms = <String>[].obs;
  final RxBool isLoading = false.obs;

  final RxList<UsersModel> matches = <UsersModel>[].obs;

  Future<void> createMatch(String receiverID, Object object) async {
    try {
      isLoading.value = true;
      String currentID = Get.find<AuthController>().user!.uid;

      await _matchService.createMatch(currentID, receiverID);
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unMatch(String other) async {
    String currentID = Get.find<AuthController>().user!.uid;
    await _matchService.unMatch(currentID, other);
  }

  Future<void> getMatches() async {
    try {
      String currentID = Get.find<AuthController>().user!.uid;

      List<UsersModel> users = await UserService().getUsers(currentID);

      matches.assignAll(users);
    } catch (e) {
      print("Error getMatches: $e");
    }

  }
}
