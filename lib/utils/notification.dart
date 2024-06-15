import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ssurade/globals.dart' as globals;

showNotification(String title, String body) async {
  await globals.flutterLocalNotificationsPlugin.show(
    globals.bgSetting.notificationId++,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        globals.channel.id,
        globals.channel.name,
        channelShowBadge: true,
        styleInformation: BigTextStyleInformation(body),
        priority: Priority.high,
        importance: Importance.high,
        ticker: "ticker",
      ),
    ),
  );
  await globals.bgSetting.saveFile();
}
