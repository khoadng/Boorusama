// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config.dart';
import 'booru.dart';
import 'booru_factory.dart';

final booruFactoryProvider =
    Provider<BooruFactory>((ref) => throw UnimplementedError());

final booruProvider =
    Provider.autoDispose.family<Booru?, BooruConfigAuth>((ref, config) {
  final booruFactory = ref.watch(booruFactoryProvider);

  return config.createBooruFrom(booruFactory);
});
