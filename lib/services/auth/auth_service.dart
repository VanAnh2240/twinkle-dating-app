import 'package:firebase_auth/firebase_auth.dart';
import 'package:twinkle/models/users_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Current Firebase user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  // Stream of UsersModel
  Stream<UsersModel?> get authStateChanges => _auth.authStateChanges().asyncMap(
        (user) async => user != null ? await _firestoreService.getUser(user.uid) : null,
      );

  // Sign in
  Future<UsersModel> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await _firestoreService.updateUserOnlineStatus(user.uid, true);
        return await _firestoreService.getUser(user.uid);
      }
      throw Exception("User not found");
    } on FirebaseAuthException catch (e) {
      throw Exception("Failed to log in: ${e.code}");
    }
  }

  // Register
  Future<UsersModel> registerWithEmailPassword(
    String email,
    String password,
    String first_name,
    String last_name,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        final userModel = UsersModel(
          user_id: null, // Firestore doc id sẽ là uid
          first_name: first_name,
          last_name: last_name,
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

        await _firestoreService.createUser(user.uid, userModel);
        return userModel;
      }
      throw Exception("Failed to register user");
    } on FirebaseAuthException catch (e) {
      throw Exception("Failed to register: ${e.code}");
    }
  }

  // Send password reset email
  Future<void> sendPwResetEmail(String email) async {
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
        await _firestoreService.deleteUser(user.uid);
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
