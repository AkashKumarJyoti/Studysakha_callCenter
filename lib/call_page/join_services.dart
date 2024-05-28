import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'access_firebase_token.dart';
import 'firebase_services.dart';
import 'package:http/http.dart' as http;


class JoinService {

  //Function to join the room
  static Future<void> join(String roomUrl, HMSSDK hmssdk, String? roomId) async {
    await FirebaseFirestore.instance
        .collection('expert_rooms')
        .doc(roomId)
        .update({'users': FieldValue.increment(1)});
    String name = FirebaseAuth.instance.currentUser?.displayName ?? "";
    HMSConfig config = HMSConfig(authToken: roomUrl, userName: name);
    await hmssdk.join(config: config);
  }

  static Future<void> sendQuiz(String messageToken, DocumentSnapshot doc) async {
    String? name = FirebaseAuth.instance.currentUser?.displayName;
    String question = doc['question'];
    String op1 = doc['option1'];
    String op2 = doc['option2'];
    String op3 = doc['option3'];
    String op4 = doc['option4'];
    String correctOption = doc['correctOption'];

    const String postUrl = 'https://fcm.googleapis.com/v1/projects/studysakha-65319/messages:send';
    AccessTokenFirebase accessTokenGetter = AccessTokenFirebase();
    String token = await accessTokenGetter.getAccessToken();
    final Map<String, dynamic> notificationData = {
      'message': {
        'notification': {
          'body': 'Incoming Call',
          'title': name,
        },
      'data': <String, dynamic>{
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'id': '1',
        'status': 'done',
        'question': question,
        'op1': op1,
        'op2': op2,
        'op3': op3,
        'op4': op4,
        'correct_option': correctOption
      },
        'android': {
          'priority': 'high',
        },
        'token': messageToken,
      },
    };

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse(postUrl),
      headers: headers,
      body: jsonEncode(notificationData),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully.');
    } else {
      print('Failed to send notification. Status code: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }
}