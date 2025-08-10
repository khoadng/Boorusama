// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config/types.dart';
import '../../../posts/post/post.dart';
import '../../tag/providers.dart';
import '../../tag/tag.dart';

final selectedViewTagQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

final showTagsProvider = FutureProvider.autoDispose
    .family<List<Tag>, (BooruConfigAuth, Post)>((ref, params) async {
      final (config, post) = params;

      final tagExtractor = ref.watch(tagExtractorProvider(config));

      if (tagExtractor == null) return [];

      return tagExtractor.extractTags(post);
    });
