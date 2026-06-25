import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/logger.dart';

/// BLE peer discovered on the local mesh.
class BlePeer {
  final String id;
  final String name;
  final int rssi;
  BlePeer({required this.id, required this.name, required this.rssi});
}

/// A frame received over BLE.
class BleFrame {
  final String from;
  final String text;
  final DateTime ts;
  BleFrame({required this.from, required this.text, required this.ts});
}

/// Controller that wraps `flutter_blue_plus` for scanning, connecting,
/// and exchanging JSON frames (text messages + small file chunks).
class BleMeshController extends Notifier<List<BlePeer>> {
  StreamSubscription? _scanSub;
  final Map<String, BluetoothCharacteristic> _writeChars = {};
  final _frameCtl = StreamController<BleFrame>.broadcast();

  Stream<BleFrame> get frames => _frameCtl.stream;

  @override
  List<BlePeer> build() {
    ref.onDispose(() {
      _scanSub?.cancel();
      try { FlutterBluePlus.stopScan(); } catch (_) {}
      _frameCtl.close();
    });
    return const [];
  }

  Future<void> ensureEnabled() async {
    if (!await FlutterBluePlus.isAvailable) {
      throw const BleFailure('Bluetooth not available on this device');
    }
    if (!await FlutterBluePlus.isOn) {
      // The OS will prompt the user. We just wait for state change.
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> startScan({String? localName}) async {
    await ensureEnabled();
    state = const [];
    _scanSub?.cancel();
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      final peers = <BlePeer>[];
      for (final r in results) {
        if (r.device.platformName.isEmpty) continue;
        peers.add(BlePeer(
          id: r.device.remoteId.str,
          name: r.device.platformName,
          rssi: r.rssi,
        ));
      }
      state = peers;
    });
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 12),
      withServices: [Guid(Mino.bleServiceUuid)],
    );
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _scanSub?.cancel();
  }

  Future<void> connectAndSubscribe(String deviceId) async {
    try {
      final device = BluetoothDevice.fromId(deviceId);
      await device.connect(timeout: const Duration(seconds: 8));
      final services = await device.discoverServices();
      for (final s in services) {
        if (s.uuid.str.toLowerCase() != Mino.bleServiceUuid) continue;
        for (final c in s.characteristics) {
          if (c.uuid.str.toLowerCase() == Mino.bleCharTxUuid) {
            _writeChars[deviceId] = c;
          }
          if (c.uuid.str.toLowerCase() == Mino.bleCharRxUuid) {
            await c.setNotifyValue(true);
            c.lastValueStream.listen((bytes) {
              if (bytes.isEmpty) return;
              final json = utf8.decode(bytes);
              _handleFrame(json);
            });
          }
        }
      }
    } catch (e, st) {
      log.e('ble connect', error: e, stackTrace: st);
      throw BleFailure('Failed to connect', cause: e);
    }
  }

  void _handleFrame(String json) {
    try {
      final m = jsonDecode(json) as Map<String, dynamic>;
      final type = m['t'] as String?;
      if (type == 'msg') {
        _frameCtl.add(BleFrame(
          from: m['from'] as String? ?? 'unknown',
          text: m['text'] as String? ?? '',
          ts: DateTime.fromMillisecondsSinceEpoch((m['ts'] as num?)?.toInt() ?? 0),
        ));
      } else if (type == 'file') {
        // Files arrive as chunks; in production they're reassembled + persisted
        // to local Hive storage. We surface a placeholder message here.
        _frameCtl.add(BleFrame(
          from: m['from'] as String? ?? 'unknown',
          text: '📎 Received file: ${m['name']} (${m['chunk']}/${m['total']})',
          ts: DateTime.now(),
        ));
      }
    } catch (e, st) {
      log.w('ble frame parse', error: e, stackTrace: st);
    }
  }

  Future<void> sendText(String deviceId, String from, String text) async {
    final c = _writeChars[deviceId];
    if (c == null) throw const BleFailure('Not connected to this peer');
    final payload = jsonEncode({
      't': 'msg',
      'id': '${DateTime.now().millisecondsSinceEpoch}',
      'from': from,
      'text': text,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
    await _writeChunked(c, payload);
  }

  Future<void> sendFile(String deviceId, String from, File f) async {
    final c = _writeChars[deviceId];
    if (c == null) throw const BleFailure('Not connected to this peer');
    final bytes = await f.readAsBytes();
    const chunkSize = 180; // safe under MTU 517 with JSON overhead
    final total = (bytes.length / chunkSize).ceil();
    for (var i = 0; i < total; i++) {
      final slice = bytes.sublist(i * chunkSize, (i + 1) * chunkSize);
      final b64 = base64Encode(slice);
      final payload = jsonEncode({
        't': 'file',
        'id': '${DateTime.now().millisecondsSinceEpoch}',
        'from': from,
        'name': f.path.split('/').last,
        'mime': 'application/octet-stream',
        'size': bytes.length,
        'chunk': i,
        'total': total,
        'data': b64,
      });
      await _writeChunked(c, payload);
      // BLE is slow — pace chunks
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> _writeChunked(BluetoothCharacteristic c, String payload) async {
    final bytes = Uint8List.fromList(utf8.encode(payload));
    const mtu = 180;
    if (bytes.length <= mtu) {
      await c.write(bytes, withoutResponse: true);
      return;
    }
    for (var i = 0; i < bytes.length; i += mtu) {
      final slice = bytes.sublist(i, (i + mtu).clamp(0, bytes.length));
      await c.write(slice, withoutResponse: true);
    }
  }
}

final bleMeshProvider =
    NotifierProvider<BleMeshController, List<BlePeer>>(BleMeshController.new);
