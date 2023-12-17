import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ssurade/globals.dart' as globals;

var _id = 0;

showNotification(String title, String body) => globals.flutterLocalNotificationsPlugin.show(
      _id++,
      title,
      body,
  NotificationDetails(
        android: AndroidNotificationDetails(
          "ssurade",
          "notice",
          channelShowBadge: true,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
    );
