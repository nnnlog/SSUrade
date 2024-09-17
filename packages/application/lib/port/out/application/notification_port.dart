abstract interface class NotificationPort {
  Future<void> sendNotification(String title, String body, int notificationId);
}
