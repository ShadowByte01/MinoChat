import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Tiny logger that respects debug mode.
final Logger log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 8,
    lineLength: 100,
    colors: true,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: kDebugMode ? Level.trace : Level.warning,
);
