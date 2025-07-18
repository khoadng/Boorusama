// Flutter imports:
import 'package:flutter/rendering.dart' show RenderAbstractViewport;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../settings/src/providers/listing_provider.dart';
import '../utils/grid_utils.dart';

final gridCacheExtentProvider = Provider<double>(
  (ref) {
    final gridSize = ref.watch(
      imageListingSettingsProvider.select((s) => s.gridSize),
    );

    return calculateCacheExtentFactor(gridSize) *
        RenderAbstractViewport.defaultCacheExtent;
  },
);
