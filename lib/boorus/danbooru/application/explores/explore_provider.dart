// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/functional.dart';

final timeScaleProvider = StateProvider<TimeScale>((ref) => TimeScale.day);
final dateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final timeAndDateProvider = Provider<Tuple2<TimeScale, DateTime>>((ref) {
  final timeScale = ref.watch(timeScaleProvider);
  final date = ref.watch(dateProvider);

  return Tuple2(timeScale, date);
}, dependencies: [
  timeScaleProvider,
  dateProvider,
]);
