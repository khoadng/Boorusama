// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../tracking.dart';
import 'reporter.dart';

final errorReporterProvider = FutureProvider<ErrorReporter>((ref) async {
  final tracker = await ref.watch(trackerProvider.future);

  return tracker.reporter;
});
