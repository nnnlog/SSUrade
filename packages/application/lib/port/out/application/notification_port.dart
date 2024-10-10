abstract interface class NotificationPort {
  Future<void> sendNotification({
    required String title,
    required String body,
    // required int notificationId,
  });
}
