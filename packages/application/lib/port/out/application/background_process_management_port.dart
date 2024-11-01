abstract interface class BackgroundProcessManagementPort {
  Future<void> registerBackgroundService(int interval);

  Future<void> unregisterBackgroundService();
}
