import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_application/port/out/application/notification_port.dart';

@Singleton(as: NotificationPort)
class NotificationService implements NotificationPort {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final AndroidNotificationChannel _channel;

  NotificationService._(this._flutterLocalNotificationsPlugin, this._channel);

  @FactoryMethod(preResolve: true)
  static Future<NotificationService> init() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final AndroidNotificationChannel channel = const AndroidNotificationChannel(
      "ssurade",
      "notice",
      importance: Importance.high,
      showBadge: true,
    );

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (NotificationResponse r) => Future.value());

    return NotificationService._(flutterLocalNotificationsPlugin, channel);
  }

  @override
  Future<void> sendNotification(String title, String body, int notificationId) async {
    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelShowBadge: true,
          styleInformation: BigTextStyleInformation(body),
          priority: Priority.high,
          importance: Importance.high,
          ticker: "ticker",
        ),
      ),
    );
  }
}
