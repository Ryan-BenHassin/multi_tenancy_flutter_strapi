import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/user_provider.dart';
import 'auth_service.dart';
import 'http_client.dart';

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HttpClient _httpClient = HttpClient();

  // Get list of users to chat with
  Future<List<Map<String, dynamic>>> getUsers() async {
    if (UserProvider.user == null) return [];
    
    // Get all users from API
    final response = await _httpClient.get('${AuthService.baseUrl}/users?populate=*');
    
    if (response is! List) return [];

    // Filter and map users
    return response.where((user) {
      // Don't show current user
      if (user['id'].toString() == UserProvider.user!.id.toString()) {
        return false;
      }
      
      // Filter based on role
      final userRole = user['roleType'];
      if (UserProvider.user!.roleType == 'DOCTOR') {
        // Doctors can only chat with patients who have completed their profile
        return userRole == 'PATIENT' && user['patient'] != null;
      } else {
        // Patients can only chat with doctors who have completed their profile
        return userRole == 'DOCTOR' && user['doctor'] != null;
      }
    }).map((user) => {
      'id': user['id'].toString(),
      'firstname': user['firstname'] ?? '',
      'lastname': user['lastname'] ?? '',
      'email': user['email'],
      'roleType': user['roleType'] ?? '',
    }).toList();
  }

  // Send a message to another user
  Future<void> sendMessage(String receiverId, String message) async {
    if (UserProvider.user == null || message.trim().isEmpty) return;
    
    try {
      final currentUser = UserProvider.user!;
      final timestamp = FieldValue.serverTimestamp();

      // Create a unique chat room ID by sorting user IDs
      List<String> ids = [currentUser.id.toString(), receiverId];
      ids.sort();
      String chatRoomId = ids.join("_");

      // Save message to Firestore
      await _firestore
          .collection("chats")
          .doc(chatRoomId)
          .collection("messages")
          .add({
            'sender': currentUser.id.toString(),
            'receiver': receiverId,
            'content': message,
            'createdAt': timestamp,
          });

      // Update chat room info
      await _firestore
          .collection("chats")
          .doc(chatRoomId)
          .set({
            'participants': [currentUser.id.toString(), receiverId],
            'lastMessage': message,
            'lastMessageTime': timestamp,
          }, SetOptions(merge: true));

    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message');
    }
  }

  // Get stream of messages for a chat
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");
    
    return _firestore
        .collection("chats")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}