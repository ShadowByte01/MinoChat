import 'package:equatable/equatable.dart';

enum ChannelRole { owner, admin, poster, subscriber }

class Channel extends Equatable {
  final String id;
  final String name;
  final String? handle;
  final String? description;
  final String? avatarUrl;
  final String ownerId;
  final List<String> adminIds;
  final List<String> posterIds;
  final int subscriberCount;
  final bool isVerified;
  final bool isPrivate;
  final DateTime createdAt;

  const Channel({
    required this.id,
    required this.name,
    this.handle,
    this.description,
    this.avatarUrl,
    required this.ownerId,
    this.adminIds = const [],
    this.posterIds = const [],
    this.subscriberCount = 0,
    this.isVerified = false,
    this.isPrivate = false,
    required this.createdAt,
  });

  factory Channel.fromMap(Map<String, dynamic> m) => Channel(
    id: m['id'] as String,
    name: m['name'] as String? ?? '',
    handle: m['handle'] as String?,
    description: m['description'] as String?,
    avatarUrl: m['avatar_url'] as String?,
    ownerId: m['owner_id'] as String,
    adminIds: (m['admin_ids'] as List<dynamic>?)?.cast<String>() ?? const [],
    posterIds: (m['poster_ids'] as List<dynamic>?)?.cast<String>() ?? const [],
    subscriberCount: (m['subscriber_count'] as int?) ?? 0,
    isVerified: (m['is_verified'] as bool?) ?? false,
    isPrivate: (m['is_private'] as bool?) ?? false,
    createdAt: DateTime.tryParse(m['created_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
  );

  @override
  List<Object?> get props => [id, subscriberCount, name];
}
