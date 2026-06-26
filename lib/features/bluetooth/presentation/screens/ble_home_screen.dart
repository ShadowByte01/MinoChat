import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:mino_chat/core/theme/colors.dart';
import '../controllers/ble_mesh_controller.dart';

/// Home of the offline mesh tab.
/// Scans for nearby Mino peers over BLE + Wi-Fi Direct (Nearby Connections).
class BleHomeScreen extends ConsumerStatefulWidget {
  const BleHomeScreen({super.key});
  @override
  ConsumerState<BleHomeScreen> createState() => _BleHomeScreenState();
}

class _BleHomeScreenState extends ConsumerState<BleHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePermissions());
  }

  Future<void> _ensurePermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    ref.read(bleMeshProvider.notifier).startScan();
  }

  @override
  Widget build(BuildContext context) {
    final peers = ref.watch(bleMeshProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mesh'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(bleMeshProvider.notifier).startScan(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: MinoGradients.primaryButton,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.bluetooth, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No internet? No problem. Mino Chat uses Bluetooth & Wi-Fi Direct to find nearby friends and chat peer-to-peer.',
                    style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: peers.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Scanning for nearby Mino peers…', style: TextStyle(color: MinoColors.muted)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: peers.length,
                    itemBuilder: (_, i) {
                      final p = peers[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: MinoColors.primaryContainer,
                          child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: MinoColors.primary, fontWeight: FontWeight.w700)),
                        ),
                        title: Text(p.name),
                        subtitle: Text('Signal: ${p.rssi} dBm'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: p.rssi > -60 ? MinoColors.success : MinoColors.warning,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p.rssi > -60 ? 'Strong' : 'Weak',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                        onTap: () async {
                          await ref.read(bleMeshProvider.notifier).connectAndSubscribe(p.id);
                          if (!mounted) return;
                          context.push('/ble/chat/${p.id}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
