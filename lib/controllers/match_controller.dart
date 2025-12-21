import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/models/matches_model.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/services/firestore_service.dart';

class MatchController extends GetxController {
  final FirestoreService firestoreService = FirestoreService();
  final AuthController authController = Get.find<AuthController>();

  final RxList<MatchesModel> _matchesShip = <MatchesModel>[].obs;
  final RxList<UsersModel> _matches = <UsersModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxList<UsersModel> _filteredMatches = <UsersModel>[].obs;
  final RxBool _isSearchOpen = false.obs;

  StreamSubscription? _matchesSubscription;

  List<MatchesModel> get matchesShip => _matchesShip.toList();
  List<UsersModel> get matches => _matches;
  List<UsersModel> get filteredMatches => _filteredMatches;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  String get searchQuery => _searchQuery.value;
  RxBool get isSearchOpen => _isSearchOpen;

  @override
  void onInit() {
    super.onInit();
    _loadMatches();

    debounce(
      _searchQuery,
      (_) => _filterMatches(),
      time: Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    _matchesSubscription?.cancel();
    super.onClose();
  }

  void _loadMatches() {
    print("Loading matches...");
    final currentUserID = authController.user?.uid;
    
    if (currentUserID == null) {
      print("No current user ID");
      _error.value = 'User not logged in';
      return;
    }

    print("Current User ID: $currentUserID");
    _isLoading.value = true;
    _matchesSubscription?.cancel();

    _matchesSubscription = firestoreService
        .getMatchesStream(currentUserID)
        .listen(
          (matchesShipList) {
            print("Received ${matchesShipList.length} matches from stream");
            
            if (matchesShipList.isEmpty) {
              print("No matches found in database");
              _matchesShip.value = [];
              _matches.value = [];
              _filteredMatches.value = [];
              _isLoading.value = false;
              return;
            }

            _matchesShip.value = matchesShipList;
            _loadMatchesDetails(currentUserID, matchesShipList);
          },
          onError: (error) {
            print("Stream error: $error");
            _error.value = error.toString();
            _isLoading.value = false;
          },
        );
  }

  void _loadMatchesDetails(String currentUserID, List<MatchesModel> matchesShipList) async {
    try {
      print("🔍 Loading details for ${matchesShipList.length} matches");
      _isLoading.value = true;
      _error.value = ''; // Clear previous errors
      
      List<UsersModel> matchesUsers = [];

      final futures = matchesShipList.map((matchShip) async {
        String matchID = matchShip.getOtherUsersId(currentUserID);
        print("👤 Fetching user: $matchID");
        return await firestoreService.getUserById(matchID);
      }).toList();

      final results = await Future.wait(futures);

      for (var matchUser in results) {
          print("Found user: ${matchUser.first_name} ${matchUser.last_name}");
          matchesUsers.add(matchUser);
      }

      print("Total matched users loaded: ${matchesUsers.length}");
      _matches.value = matchesUsers;
      _filterMatches();
      
    } catch (e) {
      print("Error loading match details: $e");
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load matches: $e',
        backgroundColor: Colors.redAccent.withOpacity(0.2),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _filterMatches() {
    final query = _searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      _filteredMatches.value = _matches;
      print("🔍 Showing all ${_matches.length} matches (no filter)");
    } else {
      _filteredMatches.value = _matches.where((match) {
        String displayName = '${match.first_name} ${match.last_name}';
        String email = match.email;
        return displayName.toLowerCase().contains(query) ||
            email.toLowerCase().contains(query);
      }).toList();
      print("Filtered to ${_filteredMatches.length} matches for query: '$query'");
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  void toggleSearch() {
    _isSearchOpen.value = !_isSearchOpen.value;
    if (!_isSearchOpen.value) {
      clearSearch();
    }
  }

  Future<void> refreshMatches() async {
    final currentUserID = authController.user?.uid;
    if (currentUserID != null) {
      _isLoading.value = true;
      _error.value = '';
      _loadMatches();
      await Future.delayed(Duration(seconds: 1)); // Give time for stream to update
    }
  }

  void _showSuccessDialog(String title, String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        backgroundColor: const Color(0xFF1E1E1E),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.lightGreenAccent,
                size: 80,
              ),
              const SizedBox(height: 32),
              Text(
                '$title!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> blockMatch(UsersModel match) async {
    _isLoading.value = true;
    try {
      final currentUserID = authController.user?.uid;
      if (currentUserID != null) {
        await firestoreService.blockUser(currentUserID, match.user_id);
        _showSuccessDialog('Blocked', "This person won't be able to see or text you again!");
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to block',
        backgroundColor: Colors.redAccent.withOpacity(0.2),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> unMatch(UsersModel match) async {
    _isLoading.value = true;
    try {
      final currentUserID = authController.user?.uid;
      if (currentUserID != null) {
        await firestoreService.unMatch(currentUserID, match.user_id);
        _showSuccessDialog('Unmatched', "You guys won't be able to see or text each other again!");
      }
    } catch (e) {
      print("Unmatch error: $e");
      Get.snackbar(
        'Error',
        'Failed to unmatch',
        backgroundColor: Colors.redAccent.withOpacity(0.2),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startChat(UsersModel match) async {
    try {
      _isLoading.value = true;
      final String currentUserID = authController.user!.uid;
      List<String> userIDs = [currentUserID, match.user_id];
      userIDs.sort();

      String chatID = '${userIDs[0]}_${userIDs[1]}';

      Get.toNamed(
        AppRoutes.chat,
        arguments: {
          'chat_id': chatID,
          'other_user': match,
        },
      );
    } catch (e) {
      print("❌ Start chat error: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  String getLastSeenText(UsersModel user) {
    if (user.is_online) return 'Online';
    else {
      final now = DateTime.now();
      final difference = now.difference(user.last_seen);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return 'Last seen ${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return 'Last seen ${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return 'Last seen ${difference.inDays}d ago';
      } else {
        return 'Last seen ${user.last_seen.day}/${user.last_seen.month}/${user.last_seen.year}';
      }
    }
  }
}