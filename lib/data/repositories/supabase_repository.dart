import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mino_chat/core/constants/app_constants.dart';
import 'package:mino_chat/core/errors/failures.dart';
import 'package:mino_chat/core/utils/logger.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import 'package:mino_chat/data/supabase/supabase_provider.dart';

/// The single source of truth for all things Supabase.
/// Each method returns typed data and converts errors into [MinoFailure].
class SupabaseRepository {
  final SupabaseClient _sb;
  SupabaseRepository(this._sb);

  // ---------------- AUTH ----------------

  Future<MinoUser> signInWithGoogleIdToken({
    required String idToken,
    String? accessToken,
  }) async {
    try {
      final res = await _sb.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      final user = res.user;
      if (user == null) throw AuthFailure('Google sign-in returned no user');
      return _upsertUserFromAuth(user);
    } on AuthFailure {
      rethrow;
    } catch (e, st) {
      log.e('signInWithGoogleIdToken', error: e, stackTrace: st);
      throw AuthFailure('Google sign-in failed', cause: e);
    }
  }

  Future<void> signOut() async {
    try {
      await _sb.auth.signOut();
    } catch (e, st) {
      log.w('signOut failed', error: e, stackTrace: st);
    }
  }

  Future<MinoUser> _upsertUserFromAuth(User u) async {
    final row = {
      'id': u.id,
      'email': u.email,
      'display_name': u.userMetadata?['full_name'] ?? u.email?.split('@').first ?? 'Mino user',
      'avatar_url': u.userMetadata?['avatar_url'],
      'last_seen': DateTime.now().toUtc().toIso8601String(),
      'status': 'online',
    };
    await _sb.from('users').upsert(row);
    final fetched = await _sb.from('users').select().eq('id', u.id).maybeSingle();
    return MinoUser.fromMap(fetched ?? row);
  }

  Future<MinoUser?> fetchUser(String id) async {
    try {
      final m = await _sb.from('users').select().eq('id', id).maybeSingle();
      if (m == null) return null;
      return MinoUser.fromMap(m);
    } catch (e, st) {
      log.w('fetchUser failed', error: e, stackTrace: st);
      return null;
    }
  }

  Future<MinoUser> updateProfile({
    required String id,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? phone,
  }) async {
    final patch = <String, dynamic>{
      if (displayName != null) 'display_name': displayName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (phone != null) 'phone': phone,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    await _sb.from('users').update(patch).eq('id', id);
    final m = await _sb.from('users').select().eq('id', id).single();
    return MinoUser.fromMap(m);
  }

  Future<void> updatePresence(String userId, UserStatus status) async {
    try {
      await _sb.from('users').update({
        'status': status.name,
        'last_seen': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);
    } catch (e, st) {
      log.w('updatePresence', error: e, stackTrace: st);
    }
  }

  // ---------------- CHATS ----------------

  Future<List<ChatRoom>> fetchChats(String userId) async {
    try {
      final res = await _sb
          .from('chats')
          .select()
          .contains('member_ids', [userId])
          .order('updated_at', ascending: false);
      return (res as List).map((m) => ChatRoom.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e, st) {
      log.w('fetchChats', error: e, stackTrace: st);
      throw NetworkFailure('Could not load chats', cause: e);
    }
  }

  Future<ChatRoom> createDirectChat(String me, String other) async {
    // Look for an existing 1:1 chat between these two
    try {
      final existing = await _sb.rpc('find_or_create_direct_chat', params: {
        'user_a': me,
        'user_b': other,
      });
      if (existing is Map) {
        return ChatRoom.fromMap(existing.cast<String, dynamic>());
      }
    } catch (_) {}
    // Fallback: do it client-side
    final row = {
      'id': 'direct_${me}_$other',
      'type': 'direct',
      'title': 'Direct',
      'member_ids': [me, other],
      'admin_ids': const [],
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    await _sb.from('chats').insert(row);
    return ChatRoom.fromMap(row);
  }

  Future<ChatRoom> createGroup({
    required String name,
    required String ownerId,
    required List<String> memberIds,
    String? description,
    String? avatarUrl,
  }) async {
    final row = {
      'type': 'group',
      'title': name,
      'description': description,
      'avatar_url': avatarUrl,
      'member_ids': [ownerId, ...memberIds],
      'admin_ids': [ownerId],
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    final res = await _sb.from('chats').insert(row).select().single();
    return ChatRoom.fromMap(res);
  }

  Future<void> pinChat(String chatId, bool pinned) async {
    await _sb.from('chats').update({'is_pinned': pinned}).eq('id', chatId);
  }

  Future<void> muteChat(String chatId, bool muted) async {
    await _sb.from('chats').update({'is_muted': muted}).eq('id', chatId);
  }

  Future<void> archiveChat(String chatId, bool archived) async {
    await _sb.from('chats').update({'is_archived': archived}).eq('id', chatId);
  }

  // ---------------- MESSAGES ----------------

  Future<List<Message>> fetchMessages({
    required String chatId,
    int limit = 50,
    DateTime? before,
  }) async {
    var q = _sb
        .from('messages')
        .select()
        .eq('chat_id', chatId);
    if (before != null) {
      q = q.lt('created_at', before.toUtc().toIso8601String());
    }
    final res = await q.order('created_at', ascending: false).limit(limit);
    return (res as List)
        .map((m) => Message.fromMap(m as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }

  Future<Message> sendMessage(Message m) async {
    final res = await _sb.from('messages').insert(m.toMap()).select().single();
    // Bump chat room
    await _sb.from('chats').update({
      'last_message_id': m.id,
      'last_message_preview': _preview(m),
      'last_message_at': m.createdAt.toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', m.chatId);
    return Message.fromMap(res);
  }

  Future<void> markRead(String chatId, String userId) async {
    await _sb.rpc('mark_chat_read', params: {'p_chat_id': chatId, 'p_user_id': userId});
  }

  Future<void> reactToMessage(String messageId, String userId, String emoji) async {
    await _sb.rpc('react_to_message', params: {
      'p_message_id': messageId,
      'p_user_id': userId,
      'p_emoji': emoji,
    });
  }

  Future<void> deleteMessage(String messageId) async {
    await _sb.from('messages').update({
      'is_deleted': true,
      'text': '',
      'attachment_url': null,
    }).eq('id', messageId);
  }

  Future<void> editMessage(String messageId, String newText) async {
    await _sb.from('messages').update({
      'text': newText,
      'edited_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', messageId);
  }

  String _preview(Message m) {
    switch (m.kind) {
      case MessageKind.text: return m.text.length > 80 ? '${m.text.substring(0, 80)}…' : m.text;
      case MessageKind.image: return '📷 Photo';
      case MessageKind.video: return '🎬 Video';
      case MessageKind.voice: return '🎤 Voice note';
      case MessageKind.audio: return '🎵 Audio';
      case MessageKind.file: return '📎 ${m.attachmentName ?? 'File'}';
      case MessageKind.sticker: return '😀 Sticker';
      case MessageKind.gif: return 'GIF';
      case MessageKind.location: return '📍 Location';
      case MessageKind.contact: return '👤 Contact';
      case MessageKind.poll: return '📊 Poll';
      case MessageKind.call: return '📞 Call';
      case MessageKind.system: return m.text;
      case MessageKind.reply: return m.text;
      case MessageKind.deleted: return '🚫 Deleted';
      case MessageKind.forwarded: return '↗ ${m.text}';
    }
  }

  // ---------------- REALTIME ----------------

  Stream<Message> watchMessages(String chatId) {
    final ctl = StreamController<Message>();
    final sub = _sb
        .channel('messages:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'chat_id', value: chatId),
          callback: (payload) {
            final m = Message.fromMap(payload.newRecord);
            ctl.add(m);
          },
        )
        .subscribe();
    ctl.onCancel = () => sub.unsubscribe();
    return ctl.stream;
  }

  Stream<ChatRoom> watchChat(String chatId) {
    final ctl = StreamController<ChatRoom>();
    final sub = _sb
        .channel('chat:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'chats',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: chatId),
          callback: (payload) => ctl.add(ChatRoom.fromMap(payload.newRecord)),
        )
        .subscribe();
    ctl.onCancel = () => sub.unsubscribe();
    return ctl.stream;
  }

  Stream<List<String>> watchTyping(String chatId) {
    final ctl = StreamController<List<String>>();
    final sub = _sb
        .channel('typing:$chatId')
        .onBroadcast(event: 'typing', callback: (m) {
          final list = (m['user_ids'] as List<dynamic>?)?.cast<String>() ?? const [];
          ctl.add(list);
        })
        .subscribe();
    ctl.onCancel = () => sub.unsubscribe();
    return ctl.stream;
  }

  Future<void> broadcastTyping(String chatId, String userId, bool isTyping) async {
    await _sb.channel('typing:$chatId').sendBroadcastMessage(
      event: 'typing',
      payload: {'user_id': userId, 'typing': isTyping, 'ts': DateTime.now().millisecondsSinceEpoch},
    );
  }

  // ---------------- PRESENCE ----------------

  Future<void> joinPresence(String chatId, String userId, Map<String, dynamic> meta) async {
    final ch = _sb.channel('presence:$chatId');
    await ch.subscribe();
    await ch.track(meta);
  }

  Future<void> leavePresence(String chatId) async {
    await _sb.channel('presence:$chatId').untrack();
  }

  // ---------------- STORAGE ----------------

  Future<String> uploadAttachment({
    required String chatId,
    required String fileName,
    required Uint8List bytes,
    required String? contentType,
    String? bucket,
  }) async {
    final path = '$chatId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _sb.storage.from(bucket ?? Mino.bucketAttachments).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: false),
    );
    return _sb.storage.from(bucket ?? Mino.bucketAttachments).getPublicUrl(path);
  }

  Future<String> uploadAvatar(String userId, Uint8List bytes, String? contentType) async {
    final path = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _sb.storage.from(Mino.bucketAvatars).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: true),
    );
    return _sb.storage.from(Mino.bucketAvatars).getPublicUrl(path);
  }

  Future<String> uploadVoiceNote(String chatId, Uint8List bytes) async {
    final path = '$chatId/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _sb.storage.from(Mino.bucketVoice).uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(contentType: 'audio/m4a'),
    );
    return _sb.storage.from(Mino.bucketVoice).getPublicUrl(path);
  }

  Future<String> uploadStory(String userId, Uint8List bytes, String? contentType) async {
    final path = '$userId/story_${DateTime.now().millisecondsSinceEpoch}';
    await _sb.storage.from(Mino.bucketStories).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType),
    );
    return _sb.storage.from(Mino.bucketStories).getPublicUrl(path);
  }

  // ---------------- SEARCH ----------------

  Future<List<MinoUser>> searchUsers(String query) async {
    if (query.trim().isEmpty) return const [];
    final res = await _sb
        .from('users')
        .select()
        .or('display_name.ilike.%$query%,email.ilike.%$query%')
        .limit(20);
    return (res as List).map((m) => MinoUser.fromMap(m as Map<String, dynamic>)).toList();
  }
}

final supabaseRepositoryProvider = Provider<SupabaseRepository>((ref) {
  final sb = ref.watch(supabaseProvider);
  return SupabaseRepository(sb);
});
