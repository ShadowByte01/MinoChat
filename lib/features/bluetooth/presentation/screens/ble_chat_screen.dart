import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/time.dart';
import '../../../data/supabase/supabase_provider.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/ble_mesh_controller.dart';

class BleChatScreen extends ConsumerStatefulWidget {
  final String peerId;
  const BleChatScreen({super.key, required this.peerId});
  @override
  ConsumerState<BleChatScreen> createState() => _BleChatScreenState();
}

class _BleChatScreenState extends ConsumerState<BleChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_MeshMsg> _msgs = [];
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = ref.read(bleMeshProvider.notifier).frames.listen((f) {
      setState(() => _msgs.add(_MeshMsg(from: f.from, text: f.text, ts: f.ts, mine: false)));
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    final me = ref.read(authControllerProvider).valueOrNull?.displayName ?? 'me';
    setState(() => _msgs.add(_MeshMsg(from: me, text: text, ts: DateTime.now(), mine: true)));
    _scrollToBottom();
    try {
      await ref.read(bleMeshProvider.notifier).sendText(widget.peerId, me, text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Send failed: $e')));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null || result.files.single.path == null) return;
    final me = ref.read(authControllerProvider).valueOrNull?.displayName ?? 'me';
    final f = File(result.files.single.path!);
    setState(() => _msgs.add(_MeshMsg(
      from: me,
      text: '📎 Sent ${f.path.split('/').last} (sending over BLE…)',
      ts: DateTime.now(),
      mine: true,
    )));
    _scrollToBottom();
    try {
      await ref.read(bleMeshProvider.notifier).sendFile(widget.peerId, me, f);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File send failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline · ${widget.peerId.substring(0, 6)}…'),
        actions: [
          IconButton(icon: const Icon(Icons.attach_file), onPressed: _pickFile),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: MinoColors.warning.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: const Row(
              children: [
                Icon(Icons.bluetooth, size: 14, color: MinoColors.warning),
                SizedBox(width: 6),
                Text('Offline mesh · messages sent over Bluetooth',
                  style: TextStyle(fontSize: 11, color: MinoColors.warning, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _msgs.length,
              itemBuilder: (_, i) {
                final m = _msgs[i];
                return Align(
                  alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: m.mine ? MinoColors.bubbleOut : MinoColors.bubbleIn,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.text, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(TimeX.clock(m.ts),
                          style: const TextStyle(fontSize: 10, color: MinoColors.muted)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: MinoColors.muted),
                    onPressed: _pickFile,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: InputDecoration(
                        hintText: 'Message…',
                        filled: true,
                        fillColor: MinoColors.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  FloatingActionButton.small(
                    heroTag: 'mesh_send',
                    onPressed: _send,
                    child: const Icon(Icons.send, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeshMsg {
  final String from;
  final String text;
  final DateTime ts;
  final bool mine;
  _MeshMsg({required this.from, required this.text, required this.ts, required this.mine});
}
