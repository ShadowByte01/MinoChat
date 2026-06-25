import 'package:equatable/equatable.dart';

enum StoryKind { image, video, text }

class Story extends Equatable {
  final String id;
  final String userId;
  final StoryKind kind;
  final String? mediaUrl;
  final String? text;
  final String? backgroundColor;
  final Duration duration;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewedBy;
  final Map<String, String> reactions; // userId -> emoji

  const Story({
    required this.id,
    required this.userId,
    required this.kind,
    this.mediaUrl,
    this.text,
    this.backgroundColor,
    this.duration = const Duration(seconds: 5),
    required this.createdAt,
    required this.expiresAt,
    this.viewedBy = const [],
    this.reactions = const {},
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory Story.fromMap(Map<String, dynamic> m) => Story(
    id: m['id'] as String,
    userId: m['user_id'] as String,
    kind: StoryKind.values.firstWhere((k) => k.name == (m['kind'] as String?), orElse: () => StoryKind.image),
    mediaUrl: m['media_url'] as String?,
    text: m['text'] as String?,
    backgroundColor: m['background_color'] as String?,
    duration: Duration(seconds: (m['duration_sec'] as int?) ?? 5),
    createdAt: DateTime.tryParse(m['created_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
    expiresAt: DateTime.tryParse(m['expires_at'] as String? ?? '')?.toLocal() ?? DateTime.now().add(const Duration(hours: 24)),
    viewedBy: (m['viewed_by'] as List<dynamic>?)?.cast<String>() ?? const [],
    reactions: (m['reactions'] as Map<String, dynamic>?)?.cast<String>() ?? {},
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'kind': kind.name,
    if (mediaUrl != null) 'media_url': mediaUrl,
    if (text != null) 'text': text,
    if (backgroundColor != null) 'background_color': backgroundColor,
    'duration_sec': duration.inSeconds,
    'created_at': createdAt.toUtc().toIso8601String(),
    'expires_at': expiresAt.toUtc().toIso8601String(),
    'viewed_by': viewedBy,
    'reactions': reactions,
  };

  @override
  List<Object?> get props => [id, viewedBy, reactions];
}
