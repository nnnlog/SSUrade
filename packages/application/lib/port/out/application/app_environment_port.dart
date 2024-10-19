abstract interface class AppEnvironmentPort {
  AppEnvironment getEnvironment();
}

enum AppEnvironment {
  debug, // DEVELOPMENT
  production
}
