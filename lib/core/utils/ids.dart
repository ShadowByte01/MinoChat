import 'package:crypto/crypto.dart';
import 'dart:convert';

class IdX {
  IdX._();

  /// Stable pseudo-id from arbitrary input (good for offline dedup)
  static String hashOf(String input) =>
      sha1.convert(utf8.encode(input)).toString().substring(0, 12);

  /// Short, friendly, collision-resistant id (used for invites, lives, etc.)
  static String shortInvite({int len = 6}) {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I
    final now = DateTime.now().microsecondsSinceEpoch;
    final seed = (now ^ DateTime.now().microsecond).toString();
    final bytes = utf8.encode(seed);
    final digest = sha1.convert(bytes);
    final sb = StringBuffer();
    for (var i = 0; i < len; i++) {
      sb.write(alphabet[digest.bytes[i] % alphabet.length]);
    }
    return sb.toString();
  }
}
