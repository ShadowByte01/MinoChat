import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:mino_chat/core/theme/colors.dart';
import 'package:mino_chat/core/utils/time.dart';
import 'package:mino_chat/data/models/chat_room_model.dart';
import 'package:mino_chat/data/models/user_model.dart';

/// One row in the chat list.
class ChatTile extends StatelessWidget {
  final ChatRoom chat;
  final MinoUser? other; // for direct chats, the peer
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ChatTile({
    super.key,
    required this.chat,
    this.other,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final title = chat.isDirect ? (other?.displayName ?? 'Mino user') : chat.title;
    final avatar = chat.isDirect ? other?.avatarUrl : chat.avatarUrl;
    final isOnline = chat.isDirect && other?.status == UserStatus.online;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: MinoColors.primaryContainer,
                  backgroundImage: avatar != null ? CachedNetworkImageProvider(avatar) : null,
                  child: avatar == null
                      ? Text(title.isNotEmpty ? title[0].toUpperCase() : '?',
                          style: const TextStyle(color: MinoColors.primary, fontWeight: FontWeight.w700, fontSize: 18))
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    right: 2, bottom: 2,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: MinoColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: MinoColors.background, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5),
                        ),
                      ),
                      if (chat.lastMessageAt != null)
                        Text(
                          TimeX.ago(chat.lastMessageAt!),
                          style: const TextStyle(color: MinoColors.muted, fontSize: 11),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (chat.isMuted) ...[
                        const Icon(Icons.volume_off, size: 14, color: MinoColors.muted),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          chat.lastMessagePreview ?? 'Tap to start chatting',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: chat.unreadCount > 0 ? MinoColors.onBackground : MinoColors.muted,
                            fontSize: 13.5,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (chat.isPinned)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.push_pin, size: 14, color: MinoColors.muted),
                        ),
                      if (chat.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: MinoColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
