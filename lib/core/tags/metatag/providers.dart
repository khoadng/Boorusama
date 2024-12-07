// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../configs/providers.dart';
import 'metatag.dart';

final metatagsProvider = Provider<Set<Metatag>>(
  (ref) => ref.watch(tagInfoProvider).metatags,
  dependencies: [tagInfoProvider],
);
