import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mino_chat/core/theme/colors.dart';

class ChannelDetailScreen extends ConsumerWidget {
  final String channelId;
  const ChannelDetailScreen({super.key, required this.channelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Channel')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Channel feed — wire to Supabase posts table here. Posts are broadcasts from channel owners to subscribers.',
            textAlign: TextAlign.center,
            style: TextStyle(color: MinoColors.muted),
          ),
        ),
      ),
    );
  }
}
