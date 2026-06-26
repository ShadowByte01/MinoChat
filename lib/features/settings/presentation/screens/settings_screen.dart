import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mino_chat/core/constants/app_constants.dart';
import 'package:mino_chat/core/theme/colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _dark = false;
  bool _enterSend = true;
  bool _readReceipts = true;
  bool _lastSeen = true;
  bool _notifyMsg = true;
  bool _notifyLive = true;
  String _quality = 'Auto';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _section('Appearance', [
            SwitchListTile(
              title: const Text('Dark mode'),
              subtitle: const Text('Use dark theme'),
              value: _dark,
              onChanged: (v) => setState(() => _dark = v),
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Accent color'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Font size'),
              trailing: const Text('Medium', style: TextStyle(color: MinoColors.muted)),
              onTap: () {},
            ),
          ]),
          _section('Chats', [
            SwitchListTile(
              title: const Text('Enter to send'),
              value: _enterSend,
              onChanged: (v) => setState(() => _enterSend = v),
            ),
            ListTile(
              leading: const Icon(Icons.wallpaper),
              title: const Text('Chat wallpaper'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup chats'),
              subtitle: const Text('Encrypted backup to your Supabase storage'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ]),
          _section('Privacy', [
            SwitchListTile(
              title: const Text('Read receipts'),
              subtitle: const Text('Show blue ticks when you read messages'),
              value: _readReceipts,
              onChanged: (v) => setState(() => _readReceipts = v),
            ),
            SwitchListTile(
              title: const Text('Last seen'),
              value: _lastSeen,
              onChanged: (v) => setState(() => _lastSeen = v),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Blocked contacts'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('App lock'),
              subtitle: const Text('Biometric lock'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ]),
          _section('Notifications', [
            SwitchListTile(
              title: const Text('Message notifications'),
              value: _notifyMsg,
              onChanged: (v) => setState(() => _notifyMsg = v),
            ),
            SwitchListTile(
              title: const Text('Live notifications'),
              value: _notifyLive,
              onChanged: (v) => setState(() => _notifyLive = v),
            ),
          ]),
          _section('Media', [
            ListTile(
              leading: const Icon(Icons.hd),
              title: const Text('Media upload quality'),
              trailing: DropdownButton<String>(
                value: _quality,
                underline: const SizedBox(),
                items: const ['Auto', 'Best', 'Data saver']
                    .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                    .toList(),
                onChanged: (v) => setState(() => _quality = v ?? 'Auto'),
              ),
            ),
          ]),
          _section('Storage & Data', [
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Manage storage'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.network_cell),
              title: const Text('Network usage'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ]),
          _section('Help', [
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help center'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('Report a bug'),
              subtitle: const Text('Opens GitHub issue'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Source code'),
              subtitle: Text(Mino.github, style: const TextStyle(fontSize: 12, color: MinoColors.muted)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
          Center(
            child: Text('Mino Chat v${Mino.version}\nMade by ${Mino.author} · ${Mino.owner}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: MinoColors.muted, fontSize: 11, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(title.toUpperCase(),
            style: const TextStyle(color: MinoColors.primary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: MinoColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: MinoColors.outline, width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
