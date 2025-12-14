import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';

  Future<void> createOrUpdateUser(User firebaseUser) async {
    final userDoc = _firestore.collection(usersCollection).doc(firebaseUser.uid);

    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      await userDoc.update({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } else {
      final user = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
        photoURL: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        isOnline: true,
      );

      await userDoc.set(user.toJson());
    }
  }

  Future<void> updateUserStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection(usersCollection).doc(user.uid).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Future<List<UserModel>> searchUsersByEmail(String query) async {
    if (query.isEmpty) return [];

    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return [];

    try {
      final snapshot = await _firestore.collection(usersCollection).get();

      final users = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .where((user) =>
      user.uid != currentUserId &&
          (user.email.toLowerCase().contains(query.toLowerCase()) ||
              user.displayName.toLowerCase().contains(query.toLowerCase())))
          .toList();

      return users;
    } catch (e) {
      print('Помилка пошуку користувачів: $e');
      return [];
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      print('Помилка отримання користувача: $e');
      return null;
    }
  }

  Future<String?> createPrivateChat(String otherUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return null;

    try {
      final existingChat = await _findExistingPrivateChat(currentUserId, otherUserId);
      if (existingChat != null) {
        return existingChat;
      }

      final otherUser = await getUserById(otherUserId);
      if (otherUser == null) return null;

      final chatDoc = _firestore.collection(chatsCollection).doc();

      final chatData = {
        'id': chatDoc.id,
        'type': 'private',
        'participants': [currentUserId, otherUserId],
        'participantDetails': {
          currentUserId: {
            'displayName': _auth.currentUser?.displayName ?? '',
            'email': _auth.currentUser?.email ?? '',
          },
          otherUserId: {
            'displayName': otherUser.displayName,
            'email': otherUser.email,
          },
        },
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUserId,
        'unreadCount': {
          currentUserId: 0,
          otherUserId: 0,
        },
      };

      await chatDoc.set(chatData);
      return chatDoc.id;
    } catch (e) {
      print('Помилка створення чату: $e');
      return null;
    }
  }

  Future<String?> _findExistingPrivateChat(String userId1, String userId2) async {
    try {
      final snapshot = await _firestore
          .collection(chatsCollection)
          .where('type', isEqualTo: 'private')
          .where('participants', arrayContains: userId1)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants']);
        if (participants.contains(userId2)) {
          return doc.id;
        }
      }
      return null;
    } catch (e) {
      print('Помилка пошуку існуючого чату: $e');
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getUserChats() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(chatsCollection)
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<Map<String, dynamic>?> getChatById(String chatId) async {
    try {
      final doc = await _firestore.collection(chatsCollection).doc(chatId).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      print('Помилка отримання чату: $e');
      return null;
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _firestore.collection(chatsCollection).doc(chatId).delete();
    } catch (e) {
      print('Помилка видалення чату: $e');
    }
  }
}