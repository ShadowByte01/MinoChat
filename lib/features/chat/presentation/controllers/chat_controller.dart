import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/chat_room_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/repositories/supabase_repository.dart';
import '../../../data/supabase/supabase_provider.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

/// Chat list controller — manages the user's chat rooms.
class ChatListController extends AsyncNotifier<List<ChatRoom>> {
  late final SupabaseRepository _repo;
  StreamSubscription? _sub;

  @override
  Future<List<ChatRoom>> build() async {
    _repo = ref.watch(supabaseRepositoryProvider);
    final me = ref.watch(authControllerProvider).valueOrNull?.id;
    if (me == null) return [];
    final initial = await _repo.fetchChats(me);
    // Subscribe to inserts/updates on chats table
    _sub = _repo.watchChat('').listen((_) {}); // dummy to keep channel alive; per-chat subs handled in ChatRoomController
    ref.onDispose(() => _sub?.cancel());
    return initial;
  }

  Future<void> refresh() async {
    final me = ref.read(authControllerProvider).valueOrNull?.id;
    if (me == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.fetchChats(me));
  }

  Future<void> pin(ChatRoom c, bool v) async {
    await _repo.pinChat(c.id, v);
    refresh();
  }

  Future<void> mute(ChatRoom c, bool v) async {
    await _repo.muteChat(c.id, v);
    refresh();
  }

  Future<void> archive(ChatRoom c, bool v) async {
    await _repo.archiveChat(c.id, v);
    refresh();
  }
}

final chatListProvider =
    AsyncNotifierProvider<ChatListController, List<ChatRoom>>(ChatListController.new);

/// Single chat room controller — messages, send, react, edit, delete.
class ChatRoomController extends FamilyAsyncNotifier<List<Message>, String> {
  late final SupabaseRepository _repo;
  late final String _chatId;
  StreamSubscription<Message>? _msgSub;

  @override
  Future<List<Message>> build(String chatId) async {
    _chatId = chatId;
    _repo = ref.watch(supabaseRepositoryProvider);
    final me = ref.watch(authControllerProvider).valueOrNull?.id;
    final initial = await _repo.fetchMessages(chatId: chatId);
    if (me != null) await _repo.markRead(chatId, me);

    _msgSub = _repo.watchMessages(chatId).listen((m) {
      final current = state.valueOrNull ?? const [];
      if (current.any((e) => e.id == m.id)) return;
      state = AsyncValue.data([...current, m]);
      if (me != null) _repo.markRead(chatId, me);
    });

    ref.onDispose(() => _msgSub?.cancel());
    return initial;
  }

  Future<void> sendText(String text, {String? replyToId, String? replyToPreview}) async {
    if (text.trim().isEmpty) return;
    final me = ref.read(authControllerProvider).valueOrNull;
    if (me == null) return;
    final msg = Message(
      id: '${me.id}_${DateTime.now().millisecondsSinceEpoch}',
      chatId: _chatId,
      senderId: me.id,
      kind: MessageKind.text,
      text: text.trim(),
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
      replyToId: replyToId,
      replyToPreview: replyToPreview,
    );
    state = AsyncValue.data([...state.valueOrNull ?? const [], msg]);
    try {
      await _repo.sendMessage(msg);
    } catch (_) {
      state = AsyncValue.data(
        (state.valueOrNull ?? const []).map((m) {
          if (m.id == msg.id) return m.copyWith(status: MessageStatus.failed);
          return m;
        }).toList(),
      );
    }
  }

  Future<void> sendAttachment(Message m) async {
    state = AsyncValue.data([...state.valueOrNull ?? const [], m]);
    try {
      await _repo.sendMessage(m);
    } catch (_) {
      state = AsyncValue.data(
        (state.valueOrNull ?? const []).map((e) {
          if (e.id == m.id) return e.copyWith(status: MessageStatus.failed);
          return e;
        }).toList(),
      );
    }
  }

  Future<void> react(String messageId, String emoji) async {
    final me = ref.read(authControllerProvider).valueOrNull;
    if (me == null) return;
    await _repo.reactToMessage(messageId, me.id, emoji);
    final list = state.valueOrNull ?? const [];
    state = AsyncValue.data(list.map((m) {
      if (m.id != messageId) return m;
      final r = Map<String, String>.from(m.reactions);
      final users = r[emoji]?.split(',') ?? [];
      if (users.contains(me.id)) {
        users.remove(me.id);
      } else {
        users.add(me.id);
      }
      if (users.isEmpty) {
        r.remove(emoji);
      } else {
        r[emoji] = users.join(',');
      }
      return m.copyWith(reactions: r);
    }).toList());
  }

  Future<void> delete(String messageId) async {
    await _repo.deleteMessage(messageId);
    final list = state.valueOrNull ?? const [];
    state = AsyncValue.data(list.map((m) {
      if (m.id != messageId) return m;
      return m.copyWith(isDeleted: true, text: '', attachmentUrl: null);
    }).toList());
  }

  Future<void> edit(String messageId, String newText) async {
    await _repo.editMessage(messageId, newText);
    final list = state.valueOrNull ?? const [];
    state = AsyncValue.data(list.map((m) {
      if (m.id != messageId) return m;
      return m.copyWith(text: newText, editedAt: DateTime.now());
    }).toList());
  }

  Future<void> loadMore() async {
    final list = state.valueOrNull;
    if (list == null || list.isEmpty) return;
    final before = list.first.createdAt;
    final older = await _repo.fetchMessages(chatId: _chatId, before: before);
    state = AsyncValue.data([...older, ...list]);
  }
}

final chatRoomProvider =
    AsyncNotifierProvider.family<ChatRoomController, List<Message>, String>(
        ChatRoomController.new);

/// Typing indicator stream
final typingProvider = StreamProvider.family<List<String>, String>((ref, chatId) {
  return ref.watch(supabaseRepositoryProvider).watchTyping(chatId);
});
