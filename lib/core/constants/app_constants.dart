/// Mino Chat — global constants & brand identity.
///
/// Made by Lost Weeds (Abhinit) · owned by X Hub.

class Mino {
  Mino._();

  /// App identity
  static const String appName = 'Mino Chat';
  static const String appTagline = 'Chat without limits.';
  static const String version = '0.1.0';
  static const int versionCode = 1;

  /// Credits
  static const String author = 'Lost Weeds (Abhinit)';
  static const String authorHandle = 'lostweeds';
  static const String owner = 'X Hub';
  static const String github = 'https://github.com/xhub/mino_chat';
  static const String supportEmail = 'hello@xhub.dev';

  /// Package
  static const String androidPackage = 'com.xhub.minochat';
  static const String iosBundleId = 'com.xhub.minochat';

  /// Backend endpoints — loaded from env at runtime, these are defaults.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR-PROJECT.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR-ANON-KEY',
  );
  static const String renderSignalingUrl = String.fromEnvironment(
    'RENDER_SIGNALING_URL',
    defaultValue: 'wss://mino-signaling.onrender.com',
  );
  static const String livekitUrl = String.fromEnvironment(
    'LIVEKIT_URL',
    defaultValue: 'wss://mino-live.livekit.cloud',
  );

  /// Google Sign-In
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// Realtime channels
  static const String channelChat = 'chat:';
  static const String channelPresence = 'presence:';
  static const String channelLive = 'live:';
  static const String channelTyping = 'typing:';

  /// Storage buckets
  static const String bucketAvatars = 'avatars';
  static const String bucketAttachments = 'attachments';
  static const String bucketVoice = 'voice_notes';
  static const String bucketStories = 'stories';
  static const String bucketFiles = 'files';

  /// BLE mesh
  static const String bleServiceUuid = '8c1f3a40-4d2b-4e7a-9b3f-4f1a6c5b9a01';
  static const String bleCharTxUuid  = '8c1f3a41-4d2b-4e7a-9b3f-4f1a6c5b9a01';
  static const String bleCharRxUuid  = '8c1f3a42-4d2b-4e7a-9b3f-4f1a6c5b9a01';

  /// Limits
  static const int maxGroupMembers = 500;
  static const int maxLiveViewers = 500;
  static const int maxLiveSpeakers = 16;
  static const int maxStoryDurationSec = 86400; // 24h
  static const int maxFileSizeMb = 2048; // 2 GB
  static const int maxVoiceNoteSec = 600; // 10 min
  static const int messagePagination = 50;

  /// Magic strings
  static const String systemSender = 'system';
  static const String deletedMarker = '🚫 message deleted';
}
