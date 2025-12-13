// import 'package:get/get.dart';
// import 'package:twinkle/controllers/auth_controller.dart';
// import 'package:twinkle/models/match_requests_model.dart';
// import 'package:twinkle/models/matches_model.dart';
// import 'package:twinkle/models/users_model.dart';
// import 'package:twinkle/services/firestore_service.dart';
// import 'package:uuid/uuid.dart';

// enum UsersMatchStatus {
//   none, 
//   matched,
//   unmatched,
//   blocked,
// }

// class MatchController extends GetxController {
//   final FirestoreService _firestoreService = FirestoreService();
//   final AuthController _authController = Get.find<AuthController>();
//   final Uuid _uuid = Uuid();

//   //State
//   final RxList<UsersModel> _users = <UsersModel>[].obs;
//   late final RxList<UsersModel> _filteredUsers = <UsersModel>[].obs;
//   final RxBool _isLoading = false.obs;
//   final RxString _error = ''.obs;

//   final RxMap<String, UsersMatchStatus> _usersStatus = <String, UsersMatchStatus>{}.obs;
  
//   final RxList<MatchesModel> _matches = <MatchesModel>[].obs;

//   //getters
//   List<UsersModel> get users => _users;
//   List<UsersModel> get filteredUsers => _filteredUsers;
//   bool get isLoading => _isLoading.value;
//   String get error => _error.value;
//   Map<String, UsersMatchStatus> get UsersStatus => _usersStatus;



//   @override
//   void onInit(){
//     super.onInit();
//     _loadAllUsers();
//   }
  
//   // ====================== LOAD DATA ======================
//   String? get currentUserID => _authController.user!.uid;

//   //load users trừ current
//   void _loadAllUsers() async{
//     if (currentUserID == null) return;

//     _isLoading.value = true;

//     _firestoreService.getAllUsersStream().listen(
//       (list) {
//         users.assignAll(
//           list.where((u) => u.user_id != currentUserID),
//         );
//         _isLoading.value = false;
//       },
//       onError: (e) {
//         _error.value = e.toString();
//         _isLoading.value = false;
//       },
//     );
//   }

//   //=========core logic==============//

//   //swiperight => requestOrCreateMatch
//   Future<void> swipeRight(UsersModel targetUser) async {
//     if (currentUserID == null) return;

//     try {
//       await _firestoreService.requestOrCreateMatch(
//         currentUserID!,
//         targetUser.user_id,
//       );
//     } catch (e) {
//       _error.value = e.toString();
//     }

//   }
//   void swipeLeft(String targetUserID) {
//     // Có thể log hoặc bỏ qua
//   }

//   // Unmatch
//   Future<void> unMatch(String otherUserID) async {
//     try {
//       await _firestoreService.unMatch(currentUserID!, otherUserID);
//       _usersStatus[otherUserID] = UsersMatchStatus.unmatched;
//       _applyFilter();
//     } catch (e) {
//       _error.value = e.toString();
//     }
//   }

//   // Block user
//   Future<void> blockUser(String otherUserID) async {
//     try {
//       await _firestoreService.blockUser(currentUserID!, otherUserID);
//       _usersStatus[otherUserID] = UsersMatchStatus.blocked;
//       _applyFilter();
//     } catch (e) {
//       _error.value = e.toString();
//     }
//   }

//   // Đồng bộ trạng thái match cho từng user
//   void _syncUsersStatus() {
//     _usersStatus.clear();

//     for (final user in _users) {
//       _usersStatus[user.user_id] = UsersMatchStatus.none;
//     }

//     for (final match in _matches) {
//       final otherID =
//           match.user1_id == currentUserID ? match.user2_id : match.user1_id;

//       _usersStatus[otherID] = UsersMatchStatus.none;
//     }
//   }

//   //Filter : Chỉ hiện thị users chưa match (UsersMatchStatus ==) + chưa block
//   void _applyFilter() {
//   }

//   Stream<List<UsersModel>> Users(){
//     return _firestoreService.getAllUsersStream();
//   }

//   UsersMatchStatus getUserStatus(String userID) {
//     return _usersStatus[userID] ?? UsersMatchStatus.none;
//   }

//   bool isMatched(String userID) =>
//       getUserStatus(userID) == UsersMatchStatus.matched;

//   bool isBlocked(String userID) =>
//       getUserStatus(userID) == UsersMatchStatus.blocked;
// }



import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/services/firestore_service.dart';

class MatchController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  // State
  final RxList<UsersModel> users = <UsersModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  String? get currentUserID => _authController.user?.uid;

  @override
  void onInit() {
    super.onInit();
    _loadAllUsers();
  }

  /// Load toàn bộ user từ Firestore
  void _loadAllUsers() {
    if (currentUserID == null) return;

    isLoading.value = true;

    _firestoreService.getAllUsersStream().listen(
      (list) {
        users.assignAll(
          list.where((u) => u.user_id != currentUserID),
        );
        isLoading.value = false;
      },
      onError: (e) {
        error.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  /// Swipe right → request hoặc auto match
  Future<void> swipeRight(String targetUserID) async {
    if (currentUserID == null) return;

    try {
      await _firestoreService.requestOrCreateMatch(
        currentUserID!,
        targetUserID,
      );
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// Swipe left → hiện tại không làm gì
  void swipeLeft(String targetUserID) {
    // Có thể log hoặc bỏ qua
  }
}
