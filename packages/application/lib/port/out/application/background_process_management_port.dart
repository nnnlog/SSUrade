abstract interface class BackgroundProcessManagementPort {
  Future<void> registerBackgroundService();

  Future<void> unregisterBackgroundService();
}
