// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'firebase.dart';
import 'foundation/errors/handlers.dart';
import 'foundation/loggers.dart';
import 'settings/providers.dart';
import 'settings/settings.dart';
import 'tracking/types.dart';

Future<Tracker> initializeTracking(
  Settings settings, {
  Logger? logger,
}) =>
    FirebaseTracker.initialize(
      settings: settings,
      logger: logger,
    );

final trackerProvider = FutureProvider<Tracker>((ref) async {
  final tracker = await FirebaseTracker.initialize(
    settings: ref.watch(settingsProvider),
    logger: ref.watch(loggerProvider),
  );

  initializeErrorHandlers(tracker.reporter);

  return tracker;
});
