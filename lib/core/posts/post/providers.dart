// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'src/types/image_url_resolver.dart';

export 'src/data/providers.dart';
export 'src/data/post_repository_builder.dart';
export 'src/data/post_repository_ext.dart';
export 'src/data/post_repository_impl.dart';
export 'src/data/post_link_generator_impl.dart';

final defaultVideoInfoExtractorProvider = Provider<VideoInfoExtractor>((ref) {
  return const DefaultVideoInfoExtractor();
});
