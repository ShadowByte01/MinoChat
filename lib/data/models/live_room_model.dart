import 'package:equatable/equatable.dart';

enum LiveKind { audio, video, screen }
enum LiveRole { host, speaker, audience }

class LiveRoom extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String hostId;
  final List<String> speakerIds;
  final List<String> audienceIds;
  final List<String> raisedHandIds;
  final LiveKind kind;
  final bool isRecording;
  final bool isLive;
  final int listenerCount;
  final String? coverUrl;
  final String? inviteCode;
  final DateTime startedAt;
  final DateTime? endedAt;

  const LiveRoom({
    required this.id,
    required this.title,
    this.description,
    required this.hostId,
    this.speakerIds = const [],
    this.audienceIds = const [],
    this.raisedHandIds = const [],
    this.kind = LiveKind.audio,
    this.isRecording = false,
    this.isLive = true,
    this.listenerCount = 0,
    this.coverUrl,
    this.inviteCode,
    required this.startedAt,
    this.endedAt,
  });

  int get totalParticipants => speakerIds.length + audienceIds.length + 1;

  factory LiveRoom.fromMap(Map<String, dynamic> m) => LiveRoom(
    id: m['id'] as String,
    title: m['title'] as String? ?? '',
    description: m['description'] as String?,
    hostId: m['host_id'] as String,
    speakerIds: (m['speaker_ids'] as List<dynamic>?)?.cast<String>() ?? const [],
    audienceIds: (m['audience_ids'] as List<dynamic>?)?.cast<String>() ?? const [],
    raisedHandIds: (m['raised_hand_ids'] as List<dynamic>?)?.cast<String>() ?? const [],
    kind: LiveKind.values.firstWhere((k) => k.name == (m['kind'] as String?), orElse: () => LiveKind.audio),
    isRecording: (m['is_recording'] as bool?) ?? false,
    isLive: (m['is_live'] as bool?) ?? true,
    listenerCount: (m['listener_count'] as int?) ?? 0,
    coverUrl: m['cover_url'] as String?,
    inviteCode: m['invite_code'] as String?,
    startedAt: DateTime.tryParse(m['started_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
    endedAt: m['ended_at'] == null ? null : DateTime.tryParse(m['ended_at'] as String)?.toLocal(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    if (description != null) 'description': description,
    'host_id': hostId,
    'speaker_ids': speakerIds,
    'audience_ids': audienceIds,
    'raised_hand_ids': raisedHandIds,
    'kind': kind.name,
    'is_recording': isRecording,
    'is_live': isLive,
    'listener_count': listenerCount,
    if (coverUrl != null) 'cover_url': coverUrl,
    if (inviteCode != null) 'invite_code': inviteCode,
    'started_at': startedAt.toUtc().toIso8601String(),
    if (endedAt != null) 'ended_at': endedAt!.toUtc().toIso8601String(),
  };

  @override
  List<Object?> get props => [id, speakerIds, audienceIds, raisedHandIds, isLive, listenerCount];
}
