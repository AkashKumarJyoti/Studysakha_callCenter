import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../call_page/call_page.dart';
import '../main.dart';

// Handling the message when the app is launched or running in the foreground
void handleMessage(RemoteMessage? message) async {
  if (message == null) return;

  print("Handling message: ${message.messageId}");
  String? title = message.notification?.title;
  String token = message.data['token'];
  String roomId = message.data['roomId'];
  String docId = message.data['docId'];
  String messageToken = message.data['message_token'];

  Get.to(() => MeetingPage(roomUrl: token, roomId: roomId, callerName: title, docId: docId, messageToken: messageToken));
}

// Background message handler
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
}

void initPushNotification() {
  FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String? title = message.notification?.title;
    String? body = message.notification?.body;
    String token = message.data['token'];
    String roomId = message.data['roomId'];
    String docId = message.data['docId'];
    String messageToken = message.data['message_token'];

    Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
      debugPrint('onActionReceivedMethod');
      if (receivedAction.buttonKeyPressed == "REJECT") {
        print("Call rejected");
      } else if (receivedAction.buttonKeyPressed == 'ACCEPT') {
        print("Call accepted");
        Get.to(() => MeetingPage(roomUrl: token, roomId: roomId, callerName: title, docId: docId, messageToken: messageToken));
      } else {
        print("Clicked on notification");
      }
    }

    if (message.notification != null) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 123,
          channelKey: "call_channel",
          color: Colors.white,
          title: title,
          body: body,
          category: NotificationCategory.Call,
          chronometer: Duration.zero,
          timeoutAfter: const Duration(seconds: 30),
          wakeUpScreen: true,
          fullScreenIntent: true,
          autoDismissible: false,
          backgroundColor: Colors.orange,
        ),
        actionButtons: [
          NotificationActionButton(
            key: "ACCEPT",
            label: "Accept Call",
            color: Colors.green,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: "REJECT",
            label: "Reject Call",
            color: Colors.red,
            autoDismissible: true,
          ),
        ],
      );
    }

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  });
}

Future initLocalNotifications() async {
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: "call_channel",
      channelName: "Call channel",
      channelDescription: "Channel of calling",
      defaultColor: Colors.redAccent,
      ledColor: Colors.white,
      importance: NotificationImportance.Max,
      channelShowBadge: true,
      locked: true,
      defaultRingtoneType: DefaultRingtoneType.Ringtone,
    ),
  ]);
}

class FirebaseApiInterface {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await initLocalNotifications();
    initPushNotification();
  }
}
