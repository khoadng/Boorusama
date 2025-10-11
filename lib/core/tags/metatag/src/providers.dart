// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/providers.dart';
import '../../../configs/config/types.dart';
import 'types/metatag.dart';

final metatagExtractorProvider =
    Provider.family<MetatagExtractor?, BooruConfigAuth>(
      (ref, config) {
        final repo = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);

        return repo?.getMetatagExtractor(config);
      },
    );
