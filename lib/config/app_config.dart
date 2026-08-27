/// Production API on Render. Override at build time if needed.
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://easy-homes-backend-obdd.onrender.com',
  );
}
