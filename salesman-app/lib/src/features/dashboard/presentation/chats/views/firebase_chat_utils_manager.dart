import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseChatUtilsManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future autheticate() async {
    await FirebaseAuth.instance.signInAnonymously();
  }

  Stream<QuerySnapshot> getMessagesStream(
    String userId, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) {
    var query = _firestore
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots();
  }

  Future<QuerySnapshot> fetchMoreMessages(
    String userId, {
    required DocumentSnapshot lastDocument,
    int limit = 20,
  }) async {
    return await _firestore
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDocument)
        .limit(limit)
        .get();
  }

  Future<void> sendMessage({
    required String userId,
    required String managerId,
    required String text,
    required VoidCallback onSuccess,
  }) async {
    if (text.isEmpty) return;

    final message = {
      'text': text,
      'senderId': userId,
      'receiverId': managerId,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    };

    try {
      // Store message in user's chat collection
      await _firestore
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .add(message);

      // If sender is manager, store in receiver's (user's) collection
      if (userId == managerId) {
        await _firestore
            .collection('chats')
            .doc(message['receiverId'] as String?)
            .collection('messages')
            .add(message);
      }

      onSuccess();
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.day}/${date.month}/${date.year}';
  }
}
