import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ssurade/globals.dart' as globals;

showNotification(String title, String body) async {
  await globals.flutterLocalNotificationsPlugin.show(
    globals.bgSetting.notificationId++,
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
  await globals.bgSetting.saveFile();
}
