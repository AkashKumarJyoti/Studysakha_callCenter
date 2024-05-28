import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../user_data/call_details.dart';
import '../user_data/navigation_bar.dart';

class NotificationService {

  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
          channelKey: "call_channel",
          channelName: "Call channel",
          channelDescription: "Channel of calling",
          defaultColor: Colors.redAccent,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true,
          defaultRingtoneType: DefaultRingtoneType.Ringtone
      )
    ]);

    await AwesomeNotifications().isNotificationAllowed().then(
          (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    await AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod
    );
  }

  /// Use this method to detect when the user taps on a notification or action button
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod');
    if (receivedAction.buttonKeyPressed == "REJECT") {
      print("Call rejected");
    }
    else if (receivedAction.buttonKeyPressed == 'ACCEPT') {
      MainApp.navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => const MyNavigationBar(),
              ),
            );
      print("Call accepted");
    }
    else {
      print("Clicked on notification");
    }
  }
}