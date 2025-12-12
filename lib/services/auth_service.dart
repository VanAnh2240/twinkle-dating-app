import 'package:firebase_auth/firebase_auth.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/services/user_service.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _UserService = UserService();

  // Current Firebase user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  // Stream of UsersModel
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in
  Future<UsersModel> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await _UserService.updateUserOnlineStatus(user.uid, true);
        return await _UserService.getUserById(user.uid);
      }
      throw Exception("User not found");
    } on FirebaseAuthException catch (e) {
      throw Exception("Failed to log in: ${e.code}");
    }
  }

  // Register
  Future<UsersModel> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        final userModel = UsersModel(
          first_name: null,
          last_name: null,
          email: email,
          password_hash: password,
          gender: null,
          date_of_birth: null,
          bio: null,
          location: null,
          profile_picture: null,
          is_online: true,
          last_seen: DateTime.now(),
          created_at: DateTime.now(),
        );

        await _UserService.createUser(user.uid, userModel);
        return userModel;
      }
      throw Exception("Failed to register user");
    } on FirebaseAuthException catch (e) {
      throw Exception("Failed to register: ${e.code}");
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception("Failed to send password reset email: ${e.code}");
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _UserService.deleteUser(user.uid);
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception("Failed to delete account: ${e.code}");
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
