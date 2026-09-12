import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../manage/providers.dart';
import '../types/thumbnail_actions.dart';

final thumbnailActionsProvider = Provider<ThumbnailActions>(
  (ref) => ref.watch(
    currentReadOnlyBooruConfigProvider.select(
      (config) => config.thumbnailActions,
    ),
  ),
);
