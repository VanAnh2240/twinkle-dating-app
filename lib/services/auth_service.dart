import 'package:firebase_auth/firebase_auth.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/services/firestore_service.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _FirestoreService = FirestoreService();

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
        await _FirestoreService.updateUserOnlineStatus(user.uid, true);
        return await _FirestoreService.getUserById(user.uid);
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
          user_id: user.uid,
          first_name: "",
          last_name: "",
          email: email,
          password_hash: password,
          gender: "",
          date_of_birth: null,
          bio: "",
          location: "",
          profile_picture: "",
          is_online: true,
          last_seen: DateTime.now(),
          created_at: DateTime.now(),
        );

        await _FirestoreService.createUser(user.uid, userModel);
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
        await _FirestoreService.deleteUser(user.uid);
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
