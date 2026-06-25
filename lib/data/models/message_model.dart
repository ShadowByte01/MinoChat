import 'package:equatable/equatable.dart';

enum MessageStatus { sending, sent, delivered, read, failed }
enum MessageKind {
  text, image, video, audio, voice, file, sticker, gif, location,
  contact, poll, system, reply, deleted, forwarded, call
}

class Message extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final MessageKind kind;
  final String text;
  final String? attachmentUrl;
  final String? attachmentName;
  final int? attachmentSize;
  final String? attachmentMime;
  final int? durationSec;        // for voice/video
  final String? thumbnailUrl;
  final String? replyToId;
  final String? replyToPreview;
  final String? forwardedFromId;
  final Map<String, String> reactions; // emoji -> userIds (joined by ",")
  final List<String> readBy;
  final List<String> deliveredTo;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isDeleted;
  final Map<String, dynamic>? metadata;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.kind = MessageKind.text,
    this.text = '',
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSize,
    this.attachmentMime,
    this.durationSec,
    this.thumbnailUrl,
    this.replyToId,
    this.replyToPreview,
    this.forwardedFromId,
    this.reactions = const {},
    this.readBy = const [],
    this.deliveredTo = const [],
    this.status = MessageStatus.sending,
    required this.createdAt,
    this.editedAt,
    this.isDeleted = false,
    this.metadata,
  });

  bool get isMine => false; // set at the UI layer using current user
  bool get hasAttachment => attachmentUrl != null;
  bool get isVoice => kind == MessageKind.voice;
  bool get isImage => kind == MessageKind.image;
  bool get isVideo => kind == MessageKind.video;
  bool get isFile => kind == MessageKind.file;
  bool get isCall => kind == MessageKind.call;

  factory Message.fromMap(Map<String, dynamic> m) => Message(
    id: m['id'] as String,
    chatId: m['chat_id'] as String,
    senderId: m['sender_id'] as String? ?? '',
    kind: MessageKind.values.firstWhere(
      (k) => k.name == (m['kind'] as String?),
      orElse: () => MessageKind.text,
    ),
    text: m['text'] as String? ?? '',
    attachmentUrl: m['attachment_url'] as String?,
    attachmentName: m['attachment_name'] as String?,
    attachmentSize: m['attachment_size'] as int?,
    attachmentMime: m['attachment_mime'] as String?,
    durationSec: m['duration_sec'] as int?,
    thumbnailUrl: m['thumbnail_url'] as String?,
    replyToId: m['reply_to_id'] as String?,
    replyToPreview: m['reply_to_preview'] as String?,
    forwardedFromId: m['forwarded_from_id'] as String?,
    reactions: (m['reactions'] as Map<String, dynamic>?)?.cast<String>() ?? {},
    readBy: (m['read_by'] as List<dynamic>?)?.cast<String>() ?? const [],
    deliveredTo: (m['delivered_to'] as List<dynamic>?)?.cast<String>() ?? const [],
    status: MessageStatus.values.firstWhere(
      (s) => s.name == (m['status'] as String?),
      orElse: () => MessageStatus.sent,
    ),
    createdAt: DateTime.tryParse(m['created_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
    editedAt: m['edited_at'] == null ? null : DateTime.tryParse(m['edited_at'] as String)?.toLocal(),
    isDeleted: (m['is_deleted'] as bool?) ?? false,
    metadata: m['metadata'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'chat_id': chatId,
    'sender_id': senderId,
    'kind': kind.name,
    'text': text,
    if (attachmentUrl != null) 'attachment_url': attachmentUrl,
    if (attachmentName != null) 'attachment_name': attachmentName,
    if (attachmentSize != null) 'attachment_size': attachmentSize,
    if (attachmentMime != null) 'attachment_mime': attachmentMime,
    if (durationSec != null) 'duration_sec': durationSec,
    if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
    if (replyToId != null) 'reply_to_id': replyToId,
    if (replyToPreview != null) 'reply_to_preview': replyToPreview,
    if (forwardedFromId != null) 'forwarded_from_id': forwardedFromId,
    'reactions': reactions,
    'read_by': readBy,
    'delivered_to': deliveredTo,
    'status': status.name,
    'created_at': createdAt.toUtc().toIso8601String(),
    if (editedAt != null) 'edited_at': editedAt!.toUtc().toIso8601String(),
    'is_deleted': isDeleted,
    if (metadata != null) 'metadata': metadata,
  };

  Message copyWith({
    MessageKind? kind,
    String? text,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    String? attachmentMime,
    int? durationSec,
    String? thumbnailUrl,
    String? replyToId,
    String? replyToPreview,
    Map<String, String>? reactions,
    List<String>? readBy,
    List<String>? deliveredTo,
    MessageStatus? status,
    DateTime? editedAt,
    bool? isDeleted,
    Map<String, dynamic>? metadata,
  }) =>
      Message(
        id: id,
        chatId: chatId,
        senderId: senderId,
        kind: kind ?? this.kind,
        text: text ?? this.text,
        attachmentUrl: attachmentUrl ?? this.attachmentUrl,
        attachmentName: attachmentName ?? this.attachmentName,
        attachmentSize: attachmentSize ?? this.attachmentSize,
        attachmentMime: attachmentMime ?? this.attachmentMime,
        durationSec: durationSec ?? this.durationSec,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        replyToId: replyToId ?? this.replyToId,
        replyToPreview: replyToPreview ?? this.replyToPreview,
        forwardedFromId: forwardedFromId,
        reactions: reactions ?? this.reactions,
        readBy: readBy ?? this.readBy,
        deliveredTo: deliveredTo ?? this.deliveredTo,
        status: status ?? this.status,
        createdAt: createdAt,
        editedAt: editedAt ?? this.editedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        metadata: metadata ?? this.metadata,
      );

  @override
  List<Object?> get props => [id, status, text, reactions, readBy, isDeleted, editedAt];
}
