// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/engine/providers.dart';
import '../../configs/config/types.dart';
import 'src/types/video_info.dart';

export 'src/data/providers.dart';
export 'src/data/post_repository_builder.dart';
export 'src/data/post_repository_ext.dart';
export 'src/data/post_repository_impl.dart';
export 'src/data/post_link_generator_impl.dart';

final defaultVideoInfoExtractorProvider = Provider<VideoInfoExtractor>((ref) {
  return const DefaultVideoInfoExtractor();
});

final videoInfoExtractorProvider =
    Provider.family<VideoInfoExtractor, BooruConfigAuth>(
      (ref, config) {
        final repository = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);

        if (repository == null) return const DefaultVideoInfoExtractor();

        return repository.videoInfoExtractor(config);
      },
      name: 'videoInfoExtractorProvider',
    );
