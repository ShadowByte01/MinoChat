import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../data/repositories/supabase_repository.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/profile-setup'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (x == null) return;
                final bytes = await x.readAsBytes();
                final url = await ref.read(supabaseRepositoryProvider).uploadAvatar(user.id, bytes, 'image/jpeg');
                await ref.read(supabaseRepositoryProvider).updateProfile(id: user.id, avatarUrl: url);
                await ref.read(authControllerProvider.notifier).refresh();
              },
              child: CircleAvatar(
                radius: 64,
                backgroundColor: MinoColors.primaryContainer,
                backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                child: user.avatarUrl == null
                    ? const Icon(Icons.camera_alt, color: MinoColors.primary)
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            Text(user.displayName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            if (user.email != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(user.email!, style: const TextStyle(color: MinoColors.muted)),
              ),
            if (user.bio != null && user.bio!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(user.bio!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
              ),
            const SizedBox(height: 32),
            _StatRow(stats: const [
              ('Chats', '∞'),
              ('Stories', '0'),
              ('Live', '0h'),
            ]),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('My QR code'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Invite friends'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings'),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
              icon: const Icon(Icons.logout, color: MinoColors.error),
              label: const Text('Sign out', style: TextStyle(color: MinoColors.error)),
            ),
            const SizedBox(height: 16),
            Text('Mino Chat v${Mino.version}\nMade by ${Mino.author} · ${Mino.owner}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: MinoColors.muted, fontSize: 11, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final List<(String, String)> stats;
  const _StatRow({required this.stats});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.map((s) => Column(
        children: [
          Text(s.$2, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(s.$1, style: const TextStyle(color: MinoColors.muted, fontSize: 12)),
        ],
      )).toList(),
    );
  }
}
