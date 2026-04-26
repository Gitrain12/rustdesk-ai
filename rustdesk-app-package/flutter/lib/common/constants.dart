class AppConstants {
  static const String appName = 'RustDesk AI';
  static const String appVersion = '1.0.0';

  static const String defaultIdServer = 'pub.hws.ru';
  static const String defaultRelayServer = 'pub.hws.ru';

  static const int defaultIdServerPort = 21116;
  static const int defaultRelayServerPort = 21117;

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration heartbeatInterval = Duration(seconds: 30);
  static const Duration reconnectDelay = Duration(seconds: 5);

  static const int maxReconnectAttempts = 5;
  static const int maxConnectionAttempts = 3;

  static const int maxImageSize = 2097152;
  static const int thumbnailSize = 512;

  static const double minToolbarOpacity = 0.0;
  static const double maxToolbarOpacity = 1.0;

  static const int videoQualityLow = 1;
  static const int videoQualityMedium = 2;
  static const int videoQualityHigh = 3;

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'zh': 'Chinese',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'ja': 'Japanese',
    'ko': 'Korean',
    'ru': 'Russian',
  };
}

class APIConstants {
  static const String aiBaseUrl = 'https://api.rustdesk-ai.com';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const int rateLimit = 100;
  static const Duration rateLimitWindow = Duration(minutes: 15);
}

class StorageKeys {
  static const String themeMode = 'theme_mode';
  static const String aiEnabled = 'ai_enabled';
  static const String serverId = 'server_id';
  static const String serverRelay = 'server_relay';
  static const String serverKey = 'server_key';
  static const String recentConnections = 'recent_connections';
  static const String savedPasswords = 'saved_passwords';
  static const String language = 'language';
  static const String qualityPreset = 'quality_preset';
}

class RouteNames {
  static const String home = '/home';
  static const String connection = '/connection';
  static const String remote = '/remote';
  static const String settings = '/settings';
  static const String server = '/server';
  static const String chat = '/chat';
  static const String fileTransfer = '/file-transfer';
}

class ErrorMessages {
  static const String connectionFailed = 'Failed to connect to remote device';
  static const String serverUnreachable = 'Server is unreachable';
  static const String authenticationFailed = 'Authentication failed';
  static const String timeout = 'Connection timed out';
  static const String networkError = 'Network error occurred';
  static const String unknownError = 'An unknown error occurred';
}