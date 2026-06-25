import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class TimeX {
  TimeX._();

  /// "14:32"
  static String clock(DateTime t) => DateFormat.Hm().format(t.toLocal());

  /// "14:32"
  static String clockFromMs(int ms) => clock(DateTime.fromMillisecondsSinceEpoch(ms));

  /// "Today", "Yesterday", "12 May"
  static String day(DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(t.year, t.month, t.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat.EEEE().format(t);
    return DateFormat('d MMM').format(t);
  }

  /// "2m ago"
  static String ago(DateTime t) => timeago.format(t.toLocal());

  /// "12 May 2025"
  static String long(DateTime t) => DateFormat('d MMMM y').format(t);

  /// "2025-05-12"
  static String isoDay(DateTime t) => DateFormat('yyyy-MM-dd').format(t);

  /// Sortable chunk key for grouped chat lists
  static String groupKey(DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(t.year, t.month, t.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat.EEEE().format(t);
    return DateFormat('d MMMM y').format(t);
  }
}
