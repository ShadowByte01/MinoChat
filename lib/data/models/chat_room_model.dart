import 'package:equatable/equatable.dart';

enum ChatType { direct, group, broadcast, channel, secret, mesh }

class ChatRoom extends Equatable {
  final String id;
  final ChatType type;
  final String title;
  final String? avatarUrl;
  final String? description;
  final List<String> memberIds;
  final List<String> adminIds;
  final String? lastMessageId;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, int> unreadByUser; // userId -> count
  final String? inviteCode;

  const ChatRoom({
    required this.id,
    required this.type,
    required this.title,
    this.avatarUrl,
    this.description,
    this.memberIds = const [],
    this.adminIds = const [],
    this.lastMessageId,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.unreadByUser = const {},
    this.inviteCode,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> m) => ChatRoom(
    id: m['id'] as String,
    type: ChatType.values.firstWhere(
      (t) => t.name == (m['type'] as String?),
      orElse: () => ChatType.direct,
    ),
    title: m['title'] as String? ?? '',
    avatarUrl: m['avatar_url'] as String?,
    description: m['description'] as String?,
    memberIds: (m['member_ids'] as List<dynamic>?)?.cast<String>() ?? const [],
    adminIds: (m['admin_ids'] as List<dynamic>?)?.cast<String>() ?? const [],
    lastMessageId: m['last_message_id'] as String?,
    lastMessagePreview: m['last_message_preview'] as String?,
    lastMessageAt: m['last_message_at'] == null
        ? null
        : DateTime.tryParse(m['last_message_at'] as String)?.toLocal(),
    unreadCount: (m['unread_count'] as int?) ?? 0,
    isPinned: (m['is_pinned'] as bool?) ?? false,
    isMuted: (m['is_muted'] as bool?) ?? false,
    isArchived: (m['is_archived'] as bool?) ?? false,
    createdAt: DateTime.tryParse(m['created_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
    updatedAt: DateTime.tryParse(m['updated_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
    unreadByUser: (m['unread_by_user'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as int)) ?? {},
    inviteCode: m['invite_code'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'title': title,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    if (description != null) 'description': description,
    'member_ids': memberIds,
    'admin_ids': adminIds,
    if (lastMessageId != null) 'last_message_id': lastMessageId,
    if (lastMessagePreview != null) 'last_message_preview': lastMessagePreview,
    if (lastMessageAt != null) 'last_message_at': lastMessageAt!.toUtc().toIso8601String(),
    'unread_count': unreadCount,
    'is_pinned': isPinned,
    'is_muted': isMuted,
    'is_archived': isArchived,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'unread_by_user': unreadByUser,
    if (inviteCode != null) 'invite_code': inviteCode,
  };

  bool get isDirect => type == ChatType.direct;
  bool get isGroup => type == ChatType.group;
  bool get isMesh => type == ChatType.mesh;
  bool get isChannel => type == ChatType.channel;

  ChatRoom copyWith({
    String? title,
    String? avatarUrl,
    String? description,
    List<String>? memberIds,
    List<String>? adminIds,
    String? lastMessageId,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isPinned,
    bool? isMuted,
    bool? isArchived,
    DateTime? updatedAt,
    String? inviteCode,
  }) =>
      ChatRoom(
        id: id,
        type: type,
        title: title ?? this.title,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        description: description ?? this.description,
        memberIds: memberIds ?? this.memberIds,
        adminIds: adminIds ?? this.adminIds,
        lastMessageId: lastMessageId ?? this.lastMessageId,
        lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
        isPinned: isPinned ?? this.isPinned,
        isMuted: isMuted ?? this.isMuted,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        unreadByUser: unreadByUser,
        inviteCode: inviteCode ?? this.inviteCode,
      );

  @override
  List<Object?> get props => [id, lastMessageId, lastMessageAt, unreadCount, isPinned];
}
