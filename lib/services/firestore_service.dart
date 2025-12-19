import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twinkle/models/blocked_users_model.dart';
import 'package:twinkle/models/chat_model.dart';
import 'package:twinkle/models/match_requests_model.dart';
import 'package:twinkle/models/matches_model.dart';
import 'package:twinkle/models/messages_model.dart';
import 'package:twinkle/models/notifications_model.dart';
import 'package:twinkle/models/profile_model.dart';
import 'package:twinkle/models/users_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 
  
  //=======================================USERS & PROFILE SETUP=======================================//
  // Create user FirebaseAuth
  Future<void> createUser(String uid, UsersModel user) async {
    try {
      final data = user.toMap();
      await _firestore.collection('Users').doc(uid).set(data); 
      print("User document created: $uid");  
    } catch (e) {
      throw Exception("Failed to create user: $e");
    }
  }

  // Get user by uid
  Future<UsersModel> getUserById(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection("Users").doc(userId).get(); 

    if (!doc.exists) {
      throw Exception("User not found");
    }
    print("Get user by id");
    return UsersModel.fromMap(doc.data()!..['user_id'] = doc.id); 
  }

  // Update online status
  Future<void> updateUserOnlineStatus(String uid, bool is_online) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('Users').doc(uid).get();
      if (doc.exists) {
        await _firestore.collection('Users').doc(uid).update({
          'is_online': is_online,
          'last_seen': Timestamp.fromDate(DateTime.now()),
        });
      }
      print("Update user online status");
    } catch (e) {
      throw Exception("Failed to update user online status: $e");
    }
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('Users').doc(uid).delete();
      print("User document deleted: $uid");
    } catch (e) {
      throw Exception("Failed to delete user: $e");
    }
  }

  Stream<UsersModel?> getUserStream(String userId) {
    return _firestore
        .collection('Users') 
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UsersModel.fromMap(doc.data()!) : null);
  }



  Future<void> updateUser(UsersModel user) async {
    try{
      await _firestore.collection('Users').doc(user.user_id).update(user.toMap());
      print("Update user");
    }catch(e){
      throw Exception('Failed to update profile');
    }
  }

  Future<void> updateUserFields(
      String userId, Map<String, dynamic> fields) async {
    await _firestore
        .collection('Users')
        .doc(userId)
        .update(fields);
  }

  // Get all User Stream
  Stream<List<UsersModel>> getAllUsersStream(){
    return _firestore.collection('Users').snapshots().map(
      (snapshot) => snapshot.docs.map(
        (doc) => UsersModel.fromMap(doc.data())
      ).toList()
    );
  }

  // Thêm vào FirestoreService
  Future<Map<String, dynamic>?> getUserDocument(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user document: $e');
      return null;
    }
  }

  //=======================================PROFILE SETUP=======================================//
  //Get user profile
  Future<ProfileModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('Profiles')
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      return ProfileModel.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  //Update user profile
  Future<void> updateProfileFields(
      String userId, Map<String, dynamic> fields) async {
    await _firestore
        .collection('Profiles')
        .doc(userId)
        .set(fields, SetOptions(merge: true));
  }

  //Check if profile exists
  Future<bool> profileExists(String userId) async {
    final doc =
        await _firestore.collection('Profiles').doc(userId).get();
    return doc.exists;
  }

  //=======================================PROFILE UPDATE=======================================//
  // Update user with partial data (Map)
  Future<void> updateUserPartial(String userId, Map<String, dynamic> data) async {
    try{
      await _firestore.collection('Users').doc(userId).update(data);
      print("Update user partial data");
    }catch(e){
      throw Exception('Failed to update user: $e');
    }
  }

  //=======================================MATCH=======================================//
  
  Future<void> requestOrCreateMatch(String currentUserID, String targetUserID) async {
    try{
      if (currentUserID == targetUserID) return;

      final reverseQuery = await _firestore
        .collection('MatchRequests')
        .where('sender_id', isEqualTo: targetUserID)
        .where('receiver_id', isEqualTo: currentUserID)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

      if(reverseQuery.docs.isNotEmpty) {
        final reverseDoc = reverseQuery.docs.first;
        await reverseDoc.reference.update({
          'status': 'matched',
        });
        
        await createMatch(currentUserID, targetUserID);
        return;
      }else {
        List<String> userIDs = [currentUserID, targetUserID];
        userIDs.sort();
        String requestID = '${userIDs[0]}_${userIDs[1]}';

        final request = MatchRequestsModel(
          request_id: requestID,
          sender_id: currentUserID,
          receiver_id: targetUserID,
          status: MatchRequestsStatus.pending,
          requested_on: DateTime.now(),
        );

        createMatchRequest(request);
      }
    }catch (e) {
      throw Exception("Failed to request or create match: $e");
    }
  }

  Future<void> createMatchRequest(MatchRequestsModel request) async {
    try{
      await _firestore.collection('MatchRequests')
        .doc(request.request_id).set(request.toMap());   
      print("Create match request");
    }catch(e){
      throw Exception("Failed to request match: $e");
    }
  }
  
  Future<void> deleteMatchRequest(String user1ID, String user2ID) async {
    try{
      List<String> userIDs = [user1ID, user2ID];
        userIDs.sort();
        String requestID = '${userIDs[0]}_${userIDs[1]}';

      await _firestore.collection('MatchRequests')
        .doc(requestID).delete();

      print("Deleted match request");
    }catch(e){
      throw Exception("Failed to request match: $e");
    }
  }

  Future<void> createMatch(String user1ID, String user2ID) async {
    try{
      List<String> userIDs = [user1ID, user2ID];
      userIDs.sort();

      String matchID = '${userIDs[0]}_${userIDs[1]}';

      MatchesModel match = MatchesModel(
        match_id: matchID, 
        user1_id: user1ID, 
        user2_id: user2ID,
        matched_at: DateTime.now(),
      );
      await _firestore.collection("Matches").doc(matchID).set(match.toMap());
      print("Created match");

      createOrGetChat(user1ID,user2ID);

      await createNotification(
            NotificationsModel(
              notification_id: DateTime.now().millisecondsSinceEpoch.toString(), 
              user_id: user1ID,
              notification_text: 'You got a new match, start to chat', 
              sent_at: DateTime.now(),
            )   
          );
    }catch(e) {
      throw Exception("Failed to create match: $e");
    }
  }

  Future<void> unMatch(String user1ID, String user2ID) async {
    try{
      if (user1ID == user2ID) return;

      List<String> userIDs = [user1ID, user2ID];
      userIDs.sort();

      String matchID = '${userIDs[0]}_${userIDs[1]}';

      await _firestore.collection('Matches').doc(matchID).delete();
      print("Unmatch");

      await createNotification (
        NotificationsModel(
          notification_id: DateTime.now().microsecondsSinceEpoch.toString(),
          user_id: user1ID,
          notification_text: 'You unmatched ${user2ID}',
          sent_at: DateTime.now(),
        )
      );

      inactiveChat(matchID);

      final requestQuery = await _firestore
        .collection('MatchRequests')
        .where('sender_id', whereIn: [user1ID, user2ID])
        .where('receiver_id', whereIn: [user1ID, user2ID])
        .where('status', isEqualTo: 'matched')
        .limit(1)
        .get();

      if (requestQuery.docs.isNotEmpty) {
        await requestQuery.docs.first.reference.update({
          'status': 'unmatched',
        });
        print("Update status match request");
      }
    }
    catch(e) {
      throw Exception("Failed to unmatch: $e");
    }
  }

  Future<void> blockUser(String blockerID, String blockedID) async {
    try{
      await createBlockedUser (blockerID, blockedID);
      unMatch(blockerID, blockedID);
    }
    catch(e) {
      throw Exception("Failed to unmatch: $e");
    }
  }

  Future<void> unBlockUser(String blockerID, String blockedID) async {
    try{
      List<String> userIDs = [blockerID, blockedID];
      String blockID = '${userIDs[0]}_${userIDs[1]}';
      
      await _firestore.collection('BlockedUsers').doc(blockID).delete();
      print("Unblock");
    }
    catch(e) {
      throw Exception("Failed to unblock: $e");
    }
  }
  
  Future<void> createBlockedUser(String blockerID, String blockedID) async {
    try {
      List<String> userIDs = [blockerID, blockedID];
      String blockID = '${userIDs[0]}_${userIDs[1]}';

      final block = {
        'block_id': blockerID,
        'user_id': blockerID,
        'blocked_user_id': blockedID,
        'blocked_on': Timestamp.fromDate(DateTime.now()),
      };

      await _firestore.collection('BlockedUsers').doc(blockID).set(block);
      print("Create blocked user");
    } catch (e) {
      throw Exception("Failed to create blocked user: $e");
    }
  }
  
  Stream<List<MatchesModel>> getMatchesStream(String userId) {
    return _firestore
        .collection('Matches')
        .where(
          Filter.or(
            Filter('user1_id', isEqualTo: userId),
            Filter('user2_id', isEqualTo: userId),
          ),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return MatchesModel.fromMap(data);
            }).toList());
  }

  Stream<List<MatchRequestsModel>> getMatchRequestsStream(String userId) {
    return _firestore
        .collection('MatchRequests')
        .where(
          Filter.or(
            Filter('sender_id', isEqualTo: userId),
            Filter('receiver_id', isEqualTo: userId),
          ),
        )
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; 
            return MatchRequestsModel.fromMap(data);
          }).toList();
        });
  }
  
  Future<MatchesModel?> getMatches(String user1ID, String user2ID) async {
    try {
      List<String> userIDs = [user1ID, user2ID];
      userIDs.sort();
      String matchID = '${userIDs[0]}_${userIDs[1]}';

      DocumentSnapshot doc = await _firestore
        .collection('Matches')
        .doc(matchID).get();

      if (doc.exists) {
        print("Get matches");
        return MatchesModel.fromMap(doc.data() as Map<String, dynamic>);
      }

      return null;
    }catch(e) {
      throw Exception("Failed to get matches: $e");
    }
  }

  Future<bool> isUserUnmatched(String userID, String otherID) async {
    try{
      List<String> userIDs = [userID,otherID];
      userIDs.sort();

      String matchID = '${userIDs[0]}_${userIDs[1]}';

      DocumentSnapshot doc = await _firestore
        .collection('Matches')
        .doc(matchID)
        .get();

      return !doc.exists || (doc.exists && doc.data() == null);
    }catch(e) {
      throw Exception("Failed to check if user is unmatched: $e");
    }
  }

  //========================================BLOCK==================================================//
  
  Future<void> createBlock({required String userId, required String blockedUserId,}) async {
    if (userId == blockedUserId) return;

    final blockRef = _firestore.collection('BlockedUsers');

    final existing = await blockRef
        .where('user_id', isEqualTo: userId)
        .where('blocked_user_id', isEqualTo: blockedUserId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    final docRef = blockRef.doc();
    List<String> userIDs = [userId, blockedUserId];  
    String blockID = '${userIDs[0]}_${userIDs[1]}';

    final block = BlockedUsersModel(
      block_id: blockID,
      user_id: userId,
      blocked_user_id: blockedUserId,
      blocked_on: DateTime.now(),
    );

    await docRef.set({
      'block_id': block.block_id,
      'user_id': block.user_id,
      'blocked_user_id': block.blocked_user_id,
      'blocked_on': Timestamp.fromDate(block.blocked_on),
    });
  }

  Future<bool> isUserBlocked(String userID, String otherID) async {
    try{
      final query = await _firestore
        .collection('BlockedUsers')
        .where('user_id', isEqualTo: otherID)
        .where('blocked_user_id', isEqualTo: userID)
        .get();

      print("Checked if user is blocked");
      return query.docs.isNotEmpty;
    }catch(e) {
      throw Exception("Failed to check if user is blocked: $e");
    }
  }

  Future<List<BlockedUsersModel>> getBlockedUsers(String userID) async {
    final snapshot = await _firestore.collection('BlockedUsers')
        .where('user_id', isEqualTo: userID)
        .get();

    final snapshot2 = await _firestore.collection('BlockedUsers')
        .where('blocked_user_id', isEqualTo: userID)
        .get();

    List<BlockedUsersModel> blocked = snapshot.docs.map((d) {
      return BlockedUsersModel.fromMap(d.data());
    }).toList();

    blocked.addAll(snapshot2.docs.map((d) => BlockedUsersModel.fromMap(d.data())));
    return blocked;
  }

  Stream<List<BlockedUsersModel>> getBlockedUsersStream(String userId) async* {
    final blockedByMe = _firestore
        .collection('BlockedUsers')
        .where('user_id', isEqualTo: userId)
        .snapshots();

    final blockedMe = _firestore
        .collection('BlockedUsers')
        .where('blocked_user_id', isEqualTo: userId)
        .snapshots();

    await for (final _ in blockedByMe) {
      final byMeSnap = await blockedByMe.first;
      final meSnap = await blockedMe.first;

      final allDocs = [
        ...byMeSnap.docs,
        ...meSnap.docs,
      ];

      yield allDocs
          .map((doc) => BlockedUsersModel.fromMap(doc.data()))
          .toList();
    }
  }

  //=======================================CHAT=======================================//

  Future<String> createOrGetChat(String user1ID, String user2ID) async {
    try{
      List<String> userIDs = [user1ID, user2ID];
      userIDs.sort();

      String chatID = '${userIDs[0]}_${userIDs[1]}';

      // ✅ FIX: Sử dụng chatID động
      DocumentReference chatRef = _firestore.collection('Chats').doc(chatID);
      DocumentSnapshot chatDoc = await chatRef.get();

      if(!chatDoc.exists) {
        ChatsModel newChat = ChatsModel(
          chat_id: chatID, 
          participants: userIDs, 
          unread_count: {user1ID: 0, user2ID: 0}, 
          delete_by: {user1ID: false, user2ID: false},
          delete_at: {user1ID: null, user2ID: null},
          last_seen_by: {user1ID: DateTime.now(), user2ID: DateTime.now()},
          created_at: DateTime.now(), 
          updated_at: DateTime.now(),
        );

        await chatRef.set(newChat.toMap());
        print("Created chat: $chatID");
      }
      else{
        ChatsModel existingChat = ChatsModel.fromMap(
          chatDoc.data() as Map<String, dynamic>,
        );
        if (existingChat.isDeleteBy(user1ID)){
          await restoreChatForUser(chatID, user1ID);
        }
        if (existingChat.isDeleteBy(user2ID)){
          await restoreChatForUser(chatID, user2ID);
        }
      }
      print("Get chat: $chatID");
      return chatID;
    }catch(e) {
      throw Exception("Failed to create or get chat: $e");
    }
  }

  // ✅ TEMPORARY FIX: Manual sorting thay vì orderBy (không cần index)
  Stream<List<ChatsModel>> getUserChatsStream(String userID) {
    return _firestore.collection('Chats')
      .where('participants', arrayContains: userID)
      // Comment out orderBy to avoid index requirement
      // .orderBy('updated_at', descending: true)
      .snapshots()
      .map((snapshot) {
        final chats = snapshot.docs
          .map((doc) => ChatsModel.fromMap(doc.data()))
          .where((chat) => !chat.isDeleteBy(userID))
          .toList();
        
        // Sort manually in code
        chats.sort((a, b) {
          final timeA = a.updated_at ?? DateTime(0);
          final timeB = b.updated_at ?? DateTime(0);
          return timeB.compareTo(timeA);
        });
        
        print("📩 getUserChatsStream: Loaded ${chats.length} chats for $userID");
        return chats;
      });
  }

  Future<void> inactiveChat(String chatID) async {
    try {
      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(chatID)
          .update({
        'is_enable': false,
      });
      print("Inactive chat");
    } catch (e) {
      throw Exception("Failed to inactivate chat: $e");
    }
  }
  
  Future<void> updateChatLastMessage(String chatID, MessagesModel message) async {
    try{
      await _firestore.collection('Chats')
      .doc(chatID).update({
        'last_message': message.message_text,
        'last_message_time': message.sent_at.millisecondsSinceEpoch,
        'last_message_sender_id': message.sender_id,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
      print("Updated chat last message");
    }catch(e) {
      throw Exception("Failed to update chat last messages: $e");
    }
  }

  Future<void> updateUserLastSeen(String chatID, String userID) async {
    try{
      await _firestore.collection('Chats').doc(chatID).update({
        'last_seen_by.$userID':DateTime.now().millisecondsSinceEpoch,
      });
      print("Updated user last seen");
    }catch(e) {
      throw Exception("Failed to update user last seen: $e");
    }
  }

  // ✅ FIX: Chỉ update, không delete document
  Future<void> deleteChatForUser(String chatID, String userID) async {
    try{
      await _firestore.collection('Chats').doc(chatID).update({
        'delete_by.$userID': true,
        'delete_at.$userID': DateTime.now().millisecondsSinceEpoch,
      });
      print("Marked chat as deleted for user");
    }catch(e) {
      throw Exception("Failed to delete chat for user: $e");
    }
  }

  Future<void> restoreChatForUser(String chatID, String userID) async {
    try{
      await _firestore.collection('Chats').doc(chatID).update({
        'delete_by.$userID': false,
      });
      print("Restore chat for user");
    }catch(e) {
      throw Exception("Failed to restore chat for user: $e");
    }
  }
  
  Future<void> updateUnreadCount (String chatID, String userID, int count) async {
    try{
      await _firestore.collection('Chats').doc(chatID)
          .update({
            'unread_count.$userID': count,
          });
      print("Updated unread messages");
    }catch(e) {
      throw Exception("Failed to upload unread messages: $e");
    }
  }

  Future<void> restoreUnreadCount (String chatID, String userID) async {
    try{
      await _firestore.collection('Chats').doc(chatID).update({
            'unread_count.$userID': 0,
          });
      print("Restored unread messages");
    }catch(e) {
      throw Exception("Failed to restore unread messages: $e");
    }
  }

  //=======================================MESSAGE=======================================//
  
  Future<void> sendMessage(MessagesModel message) async {
    try{
      await _firestore.collection('Messages')
        .doc(message.message_id)
        .set(message.toMap());

      print("Created collection message");

      String chatID = await createOrGetChat(
        message.sender_id, 
        message.receiver_id,
      );

      await updateChatLastMessage(chatID, message);
      await updateUserLastSeen(chatID, message.sender_id);

      DocumentSnapshot chatDoc = await _firestore
        .collection('Chats')
        .doc(chatID)
        .get();
      
      if (chatDoc.exists) {
        ChatsModel chat = ChatsModel.fromMap(
          chatDoc.data() as Map<String,dynamic>,
        );

        int count = chat.getUnreadCount(message.receiver_id);

        await updateUnreadCount(chatID, message.receiver_id, count+1);
      }
    }catch(e) {
      throw Exception("Failed to send message: $e");
    }
  }

  Stream<List<MessagesModel>> getMessagesStream(String user1ID, String user2ID) {
    List<String> ids = [user1ID, user2ID];
    ids.sort();
    String chatID = '${ids[0]}_${ids[1]}';

    Stream<ChatsModel?> chatStream = _firestore
        .collection('Chats')
        .doc(chatID)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return ChatsModel.fromMap(doc.data() as Map<String, dynamic>);
          }
          return null;
        });

    Stream<QuerySnapshot> messagesStream = _firestore
        .collection('Messages')
        .where('sender_id', whereIn: [user1ID, user2ID])
        .snapshots();

    return messagesStream.asyncMap((msgSnapshot) async {
      ChatsModel? chat;
      try {
        chat = await chatStream.first.timeout(Duration(seconds: 5));
      } catch (e) {
        print("Error getting chat: $e");
        chat = null;
      }

      List<MessagesModel> messages = [];

      for (var doc in msgSnapshot.docs) {
        final msg = MessagesModel.fromMap(doc.data() as Map<String, dynamic>);

        bool isBetweenTwoUsers = 
            (msg.sender_id == user1ID && msg.receiver_id == user2ID) ||
            (msg.sender_id == user2ID && msg.receiver_id == user1ID);

        if (!isBetweenTwoUsers) continue;

        bool shouldAdd = true;

        if (chat != null) {
          final user1DeletedAt = chat.getDeleteAt(user1ID);
          if (user1DeletedAt != null && msg.sent_at.isBefore(user1DeletedAt)) {
            shouldAdd = false;
          }

          final user2DeletedAt = chat.getDeleteAt(user2ID);
          if (user2DeletedAt != null && msg.sent_at.isBefore(user2DeletedAt)) {
            shouldAdd = false;
          }
        }

        if (shouldAdd) messages.add(msg);
      }

      messages.sort((a, b) => a.sent_at.compareTo(b.sent_at));
      return messages;
    });
  }
  
  Future<void> markMessageAsRead(String messageID) async {
    try{
      await _firestore.collection('Messages').doc(messageID).update({
        'is_read': true,
      });
      print("Mark message as read");
    }catch(e) {
      throw Exception("Failed to mark message as read: $e");
    }
  }
  
  //=======================================NOTIFICATIONS=======================================//
  
  Future<void> createNotification(NotificationsModel notification) async {
    try{
      await _firestore
        .collection('Notifications')
        .doc(notification.notification_id)
        .set(notification.toMap());

      print("Create notification");
    }catch(e) {
      throw Exception("Failed to create notification: $e");
    }
  }

  // ✅ TEMPORARY FIX: Manual sorting thay vì orderBy
  Stream<List<NotificationsModel>> getNotificationsStream(String userID) {
    return _firestore.collection('Notifications')
      .where('user_id', isEqualTo: userID)
      // Comment out orderBy to avoid index requirement
      // .orderBy('sent_at', descending: true)
      .snapshots()
      .map((snapshot) {
        final notifs = snapshot.docs
          .map((doc) => NotificationsModel.fromMap(doc.data()))
          .toList();
        
        // Sort manually in code
        notifs.sort((a, b) => b.sent_at.compareTo(a.sent_at));
        
        print("🔔 getNotificationsStream: Loaded ${notifs.length} notifications");
        return notifs;
      });
  }

  Future<void> markNotificationAsRead(String notificationID) async {
    try{
      await _firestore.collection('Notifications').doc(notificationID).update({
        'is_read' : true,
      });

      print("Mark notification as read");
    }catch(e) {
      throw Exception("Failed to mark notification as read: $e");
    }
  }

  Future<void> markAllNotificationAsRead(String userID) async {
    try{
      QuerySnapshot notifications = await _firestore.collection('Notifications')
        .where('user_id', isEqualTo: userID)
        .where('is_read', isEqualTo: false)
        .get();

      WriteBatch b = _firestore.batch();

      for (var doc in notifications.docs) {
        b.update(doc.reference, {'is_read': true});
      }
      await b.commit();
      print("Mark all notifications as read");
    }catch(e) {
      throw Exception("Failed to mark all notification as read: $e");
    }
  }

  Future<void> deleteNotification(String notificationID) async {
    try{
      await _firestore.collection('Notifications').doc(notificationID).delete();
      print("Delete notification");
    }catch(e) {
      throw Exception("Failed to delelte notification: $e");
    }
  }

  Future<void> createProfile(String userId, ProfileModel newProfile) async {}

}