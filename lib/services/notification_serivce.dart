import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/user_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('User granted permission: ${settings.authorizationStatus}');

      final fcmToken = await _fcm.getToken();
      print('\n\nInitial FCM Token: $fcmToken\n\n');
      
// -------------------- THIS IS FOR FIREBASE STUDENTS --------------------
      // if (fcmToken != null && UserProvider.user != null) {
      //   await saveUserFCMToken(fcmToken);
      // }
// -------------------- THIS IS FOR FIREBASE STUDENTS --------------------

      _fcm.onTokenRefresh.listen((newToken) async {
        print('\n\nToken refreshed: $newToken\n\n');
        if (UserProvider.user != null) {
          await saveUserFCMToken(newToken);
        }
      });
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> saveUserFCMToken(String token) async {
    if (UserProvider.user == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(UserProvider.user!.id.toString())
          .set({
            'fcmToken': token,
            'lastSeen': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      print('Token saved successfully for user: ${UserProvider.user!.id}');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }
}