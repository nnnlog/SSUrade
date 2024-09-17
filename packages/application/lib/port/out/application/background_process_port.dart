abstract interface class BackgroundProcessPort {
  Future<void> registerBackgroundService();

  Future<void> unregisterBackgroundService();
}
