// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'app_logger.dart';
import 'logger.dart';

final appLoggerProvider = Provider<AppLogger>((ref) {
  throw UnimplementedError();
});

final loggerProvider = Provider<Logger>((ref) => throw UnimplementedError());
