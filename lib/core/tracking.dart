// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'firebase.dart';
import 'foundation/errors/handlers.dart';
import 'foundation/loggers.dart';
import 'settings/providers.dart';
import 'tracking/types.dart';

final trackerProvider = FutureProvider<Tracker?>((ref) async {
  final tracker = await FirebaseTracker.initialize(
    settings: ref.watch(initialSettingsProvider),
    logger: ref.watch(loggerProvider),
  );

  initializeErrorHandlers(tracker.reporter);

  return tracker;
});
