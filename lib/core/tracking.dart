// Project imports:
import 'firebase.dart';
import 'foundation/loggers.dart';
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
