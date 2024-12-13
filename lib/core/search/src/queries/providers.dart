// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/booru/booru.dart';
import '../../../configs/config.dart';
import '../../../configs/ref.dart';
import 'tag_query_composer.dart';

final tagQueryComposerProvider =
    Provider.family<TagQueryComposer, BooruConfigSearch>(
  (ref, config) => switch (config.booruType) {
    BooruType.danbooru => DanbooruTagQueryComposer(config: config),
    BooruType.gelbooru => GelbooruTagQueryComposer(config: config),
    BooruType.gelbooruV2 => GelbooruV2TagQueryComposer(config: config),
    BooruType.e621 => LegacyTagQueryComposer(config: config),
    BooruType.moebooru => LegacyTagQueryComposer(config: config),
    BooruType.szurubooru => SzurubooruTagQueryComposer(config: config),
    _ => DefaultTagQueryComposer(config: config),
  },
);

final currentTagQueryComposerProvider = Provider<TagQueryComposer>(
  (ref) {
    final config = ref.watchConfigSearch;

    return ref.watch(tagQueryComposerProvider(config));
  },
);
