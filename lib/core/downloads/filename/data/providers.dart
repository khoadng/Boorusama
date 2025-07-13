// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/providers.dart';
import '../../../configs/config/types.dart';
import '../types/generator.dart';

final downloadFilenameBuilderProvider =
    Provider.family<DownloadFilenameGenerator?, BooruConfigAuth>(
      (ref, config) {
        final repository = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);

        if (repository == null) {
          return null;
        }

        return repository.downloadFilenameBuilder(config);
      },
      name: 'downloadFilenameBuilderProvider',
    );
