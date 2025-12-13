import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twinkle/models/chat_model.dart';
import 'package:twinkle/models/match_requests_model.dart';
import 'package:twinkle/models/matches_model.dart';
import 'package:twinkle/models/messages_model.dart';
import 'package:twinkle/models/notifications_model.dart';
import 'package:twinkle/models/users_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  //=======================================USERS=======================================//

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
        .collection("Users")
        .doc(userId)
        .get();

    if (!doc.exists) {
      throw Exception("User not found");
    }

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
    } catch (e) {
      throw Exception("Failed to update user online status: $e");
    }
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('Users').doc(uid).delete();
    } catch (e) {
      throw Exception("Failed to delete user: $e");
    }
  }

  //getUserStream => theo doi realtime changes từ collection 'Users'
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
    }catch(e){
      throw Exception('Failed to update profile');
    }
  }

  // Get all User Stream
  Stream<List<UsersModel>> getAllUsersStream(){
    return _firestore.collection('Users').snapshots().map(
      (snapshot) => snapshot.docs.map(
        (doc) => UsersModel.fromMap(doc.data())
      ).toList()
    );
  }

  //=======================================MATCH=======================================//
  
  //request / createMatch
  Future<void> requestOrCreateMatch(String currentUserID, String targetUserID) async {
    try{
      // Logic:
      // - Nếu đối phương đã quẹt phải mình => tạo match
      // - Nếu chưa => lưu request (interest 1 chiều)

      if (currentUserID == targetUserID) return;

      
      //check request ngược từ target-> current
      final reverseQuery = await _firestore
        .collection('MatchRequests')
        .where('sender_id', isEqualTo: targetUserID)
        .where('receiver_id', isEqualTo: currentUserID)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

      if(reverseQuery.docs.isNotEmpty) {
        //cập nhật matchrequest status = matched
        final reverseDoc = reverseQuery.docs.first;
        await reverseDoc.reference.update({
          'status': 'matched',
        });
        
        await createMatch(currentUserID, targetUserID);

        return;
      }else {
        //tạo request match
        List<String> userIDs = [currentUserID, targetUserID];
        userIDs.sort();
        String requestID = '${userIDs[0]}_${userIDs[1]}_$currentUserID';

        final request = MatchRequestsModel(
          request_id: requestID,
          sender_id: currentUserID,
          receiver_id: targetUserID,
          status: MatchRequestsStatus.pending,
          requested_on: DateTime.now(),
        );

        createRequestMatch(request);
      }

    }catch (e) {
      throw Exception("Failed to request or create match: $e");
    }
  }
  
  //create match request 
  Future<void> createRequestMatch(MatchRequestsModel request) async {
    try{
      await _firestore.collection('MatchRequests')
        .doc(request.request_id)
        .set(request.toMap());
    }catch(e){
      throw Exception("Failed to request match: $e");
    }
  }

  //create match = create notification
  Future<void> createMatch(String user1ID, String user2ID) async {
    try{
      List<String> userIDs = [user1ID, user2ID];
      userIDs.sort();

      String matchID = '${userIDs[0]}_${userIDs[1]}';

      //add to firestore
      MatchesModel match = MatchesModel(
        match_id: matchID, 
        user1_id: user1ID, 
        user2_id: user2ID,
        matched_at: DateTime.now(),
      );
      await _firestore.collection("Matches").doc(matchID).set(match.toMap());

      //notification
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

  //unmatch -> create notification + inactive chat + update status match request
  Future<void> unMatch(String user1ID, String user2ID) async {
    try{
      if (user1ID == user2ID) return;

      List<String> userIDs = [user1ID, user2ID];
      userIDs.sort();

      String matchID = '${userIDs[0]}_${userIDs[1]}';

      //delete match
      await _firestore.collection('Matches').doc(matchID).delete();

      //notification cho unmatcher
      await createNotification (
        NotificationsModel(
          notification_id: DateTime.now().microsecondsSinceEpoch.toString(),
          user_id: user1ID,
          notification_text: 'You unmatched ${user2ID}',
          sent_at: DateTime.now(),
        )
      );

      //inactive chat
      inactiveChat(matchID);

      //update status match request
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
      }

    }
    catch(e) {
      throw Exception("Failed to unmatch: $e");
    }
  }

  //block user => unmatch
  Future<void> blockUser(String blockerID, String blockedID) async {
    try{
      //create block
      await createBlockedUser (blockerID, blockedID);
      unMatch(blockerID, blockedID);
    }
    catch(e) {
      throw Exception("Failed to unmatch: $e");
    }
  }

  //unblock user
  Future<void> unBlockUser(String blockerID, String blockedID) async {
    try{
      List<String> userIDs = [blockerID, blockedID];
      String blockID = '${userIDs[0]}_${userIDs[1]}';
      
      //un block
      await _firestore.collection('BlockedUsers').doc(blockID).delete();
    }
    catch(e) {
      throw Exception("Failed to unblock: $e");
    }
  }
  
  //create block usser
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
    } catch (e) {
      throw Exception("Failed to create blocked user: $e");
    }
  }
  
  //get matches stream except block list
  Stream<List<MatchesModel>> getMatchesStream(String userID) {
    return _firestore.collection('Matches')
      .where('user1_id',isEqualTo: userID)
      .snapshots()
      .asyncMap((snapshot1) async {
        QuerySnapshot snapshot2 = await _firestore
          .collection('Matches')
          .where('user2_id',isEqualTo: userID).get();
        
        List<MatchesModel> matches = [];

        for (var doc in snapshot1.docs) {
          matches.add(
            MatchesModel.fromMap(doc.data() as Map<String, dynamic>),
          );
        }

        for (var doc in snapshot2.docs) {
          matches.add(
            MatchesModel.fromMap(doc.data() as Map<String, dynamic>),
          );
        }

        //list block
        final blockedSnapshot = await _firestore
            .collection('BlockedUsers')
            .get();

        //lấy danh sách user bị block hoặc đã block
        final blockedUsers = blockedSnapshot.docs.map((doc) {
          final data = doc.data();
          return [
            data['user_id'] as String,
            data['blocked_user_id'] as String
          ];
        }).expand((ids) => ids).toSet();

        // lọc match: đối phương không được nằm trong blocklist
        final filteredMatches = matches.where((match) {
          final otherID = match.user1_id == userID ? match.user2_id : match.user1_id;
          return !blockedUsers.contains(otherID);
        }).toList();


        return filteredMatches;

      });
  }

  //get matches
  Future<MatchesModel?> getMatches(String user1ID, String user2ID) async {
    try {
      List<String> userIDs = [user1ID, user2ID];
      userIDs.sort();
      String matchID = '${userIDs[0]}_${userIDs[1]}';

      DocumentSnapshot doc = await _firestore
        .collection('Matches')
        .doc(matchID).get();

      if (doc.exists) {
        return MatchesModel.fromMap(doc.data() as Map<String, dynamic>);
      }

      return null;

    }catch(e) {
      throw Exception("Failed to get matches: $e");
    }
  }

  //check if user is blocked?
  Future<bool> isUserBlocked(String userID, String otherID) async {
    try{
      final query = await _firestore
        .collection('BlockedUsers')
        .where('user_id', isEqualTo: otherID)
        .where('blocked_user_id', isEqualTo: userID)
        .get();

      return query.docs.isNotEmpty;

    }catch(e) {
      throw Exception("Failed to check if user is blocked: $e");
    }
  }

  //check if a user is unmatched
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

  //=======================================CHAT=======================================//

  //create chat: Nếu 2 người đã có chat room => truy cập; chưa có => tạo mới
  Future<String> createOrGetChat(String user1ID, String user2ID) async {
    try{
      List<String> userIDs = [user1ID, user2ID];
      userIDs.sort();

      String chatID = '${userIDs[0]}_${userIDs[1]}';

      DocumentReference chatRef = _firestore.collection('Chats').doc('chat_id');
      DocumentSnapshot chatDoc = await chatRef.get();

      if(!chatDoc.exists) {
        ChatsModel newChat = ChatsModel(
          chat_id: chatID, 
          is_enable: true, 
          participants: userIDs, 
          unread_count: {user1ID: 0, user2ID: 0}, 
          delete_by: {user1ID: false, user2ID: false},
          delete_at: {user1ID: null, user2ID: null},
          last_seen_by: {user1ID: DateTime.now(), user2ID: DateTime.now()},
          created_at: DateTime.now(), 
          updated_at: DateTime.now(),
        );

        await chatRef.set(newChat.toMap());
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
      return chatID;

    }catch(e) {
      throw Exception("Failed to check if user is unmatched: $e");
    }
  }

  //get chats stream of user
  Stream<List<ChatsModel>> getUserChatsStream(String userID) {
    return _firestore.collection('Chats')
      .where('participants', arrayContains: userID)
      .orderBy('updated_at', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
          .map((doc) => ChatsModel.fromMap(doc.data()))
          .where((chat) => !chat.isDeleteBy(userID))
          .toList(),
      );
  }

  //inactive chat for both users
  Future<void> inactiveChat(String chatID) async {
    try {
      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(chatID)
          .update({
        'is_enable': false,
      });
    } catch (e) {
      throw Exception("Failed to inactivate chat: $e");
    }
  }
  
  //update last mess
  Future<void> updateChatLastMessage(String chatID, MessagesModel message) async {
    try{
      await _firestore.collection('Chats')
      .doc(chatID).update({
        'last_message': message.message_text,
        'last_message_time': message.sent_at.millisecondsSinceEpoch,
        'last_message_sender_id': message.sender_id,
        'update_at': DateTime.now().millisecondsSinceEpoch,
      });
    }catch(e) {
      throw Exception("Failed to update chat last messages: $e");
    }
  }

  //update user last seen
  Future<void> updateUserLastSeen(String chatID, String userID) async {
    try{
      await _firestore.collection('Chats').doc(chatID).update({
        'last_seen_by.${userID}':DateTime.now().millisecondsSinceEpoch,
      });
    }catch(e) {
      throw Exception("Failed to update user last seen: $e");
    }
  }

  //delete chat for user
  Future<void> deleteChatForUser(String chatID, String userID) async {
    try{
      await _firestore.collection('Chats').doc(chatID).update({
        'delete_by.$userID': true,
        'delete_at.${userID}': DateTime.now().millisecondsSinceEpoch,
      });

      await _firestore.collection('Chats').doc(chatID).delete();

    }catch(e) {
      throw Exception("Failed to delete chat for user: $e");
    }
  }

  //restore chat for user
  Future<void> restoreChatForUser(String chatID, String userID) async {
    try{
      await _firestore.collection('Chats').doc(chatID).update({
        'deleted_by.$userID': false,
      });
    }catch(e) {
      throw Exception("Failed to restore chat for user: $e");
    }
  }
  
  //update unread messages
  Future<void> updateUnreadCount (String chatID, String userID, int count) async {
    try{
      await _firestore.collection('Chats').doc(chatID)
          .update({
            'unread_count': count,
          });
    }catch(e) {
      throw Exception("Failed to upload unread messages: $e");
    }
  }

  //seen -> restore unread messagess = 0
  Future<void> restoreUnreadCount (String chatID, String userID) async {
    try{
      await _firestore.collection('Chats').doc(chatID).update({
            'unread_count.$userID': 0,
          });
    }catch(e) {
      throw Exception("Failed to restore unread messages: $e");
    }
  }

  //=======================================MESSAGE=======================================//
  
  //send message => update chat last + user last seen + unread count
  Future<void> sendMessage(MessagesModel message) async {
    try{
      await _firestore.collection('Messages')
        .doc(message.message_id)
        .set(message.toMap());
      
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

  //get stream message cuar 2 nguoi + lọc các tin nhắn đã bị xóa xóa (delete_at)
  Stream<List<MessagesModel>> getMessagesStream(String user1ID, String user2ID) {
    return _firestore
        .collection('Messages')
        // message có sender là 1 trong 2 người
        .where('sender_id', whereIn: [user1ID, user2ID])
        .snapshots()
        .asyncMap((snapshot) async {
          
      List<String> ids = [user1ID, user2ID];
      ids.sort();
      String chatID = '${ids[0]}_${ids[1]}';

      // Lấy dữ liệu chat 
      final chatDoc = await _firestore.collection('Chats').doc(chatID).get();
      ChatsModel? chat;
      if (chatDoc.exists) {
        chat = ChatsModel.fromMap(chatDoc.data() as Map<String, dynamic>);
      }

      List<MessagesModel> messages = [];

      for (var doc in snapshot.docs) {
        final msg = MessagesModel.fromMap(doc.data());

        // Điều kiện lọc tin năhsn giữa 2 người - loại trư tin gửi cho người khác)
        bool isBetweenTwoUsers = 
            (msg.sender_id == user1ID && msg.receiver_id == user2ID) ||
            (msg.sender_id == user2ID && msg.receiver_id == user1ID);

        if (!isBetweenTwoUsers) continue;

        bool shouldAdd = true;

        // Nếu có dữ liệu chat -> kiểm tra delete_at
        if (chat != null) {

          // Messages cũ hơn thời gian user1 xóa chatbox => user1 không thấy tin nhắn
          final user1DeletedAt = chat.getDeleteAt(user1ID);
          if (user1DeletedAt != null && msg.sent_at.isBefore(user1DeletedAt)) {
            shouldAdd = false;
          }

          // Messages cũ hơn thời điểm user2 xóa chatbox => user2 không thấy
          final user2DeletedAt = chat.getDeleteAt(user2ID);
          if (user2DeletedAt != null && msg.sent_at.isBefore(user2DeletedAt)) {
            shouldAdd = false;
          }
        }

        // Nếu tin nhắn hợp lệ => thêm vào list
        if (shouldAdd) messages.add(msg);
      }

      messages.sort((a, b) => a.sent_at.compareTo(b.sent_at));
      return messages;
    });
  }

  //mark as read
  Future<void> markMessageAsRead(String messageID) async {
    try{
      await _firestore.collection('Messages').doc(messageID).update({
        'is_read': true,
      });
    }catch(e) {
      throw Exception("Failed to mark message as read: $e");
    }
  }
  
  //=======================================NOTIFICATIONS=======================================//
  
  //create noti
  Future<void> createNotification(NotificationsModel notification) async {
    try{
      await _firestore
        .collection('Notifications')
        .doc(notification.notification_id)
        .set(notification.toMap());
    }catch(e) {
      throw Exception("Failed to create notification: $e");
    }
  }

  //get noti
  Stream<List<NotificationsModel>> getNotificationsStream(String userID) {
    return _firestore.collection('Notifications')
      .where('user_id', isEqualTo: userID)
      .orderBy('sent_at', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
          .map((doc) => NotificationsModel.fromMap(doc.data()))
          .toList());
  }

  //mark as read
  Future<void> markNotificationAsRead(String notificationID) async {
    try{
      await _firestore.collection('Notifications').doc(notificationID).update({
        'isRead' : true,
      });
    }catch(e) {
      throw Exception("Failed to mark notification as read: $e");
    }
  }

  //mark all notifications as read
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
    }catch(e) {
      throw Exception("Failed to mark all notification as read: $e");
    }
  }

  //delete notification
  Future<void> deleteNotification(String notificationID) async {
    try{
      await _firestore.collection('Notifications').doc(notificationID).delete();
    }catch(e) {
      throw Exception("Failed to delelte notification: $e");
    }
  }
  
}
