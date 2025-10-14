// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/search/queries/providers.dart';
import '../../../core/settings/providers.dart';
import 'search_provider.dart';

final eshuushuuPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
      (ref, config) {
        final tagComposer = ref.watch(defaultTagQueryComposerProvider(config));
        final searchNotifier = ref.watch(
          eshuushuuPostSearchProvider(config.auth).notifier,
        );

        return PostRepositoryBuilder(
          tagComposer: tagComposer,
          getSettings: () async => ref.read(imageListingSettingsProvider),
          fetchSingle: (id, {options}) {
            // e-shuushuu doesn't support fetching single post by ID
            return Future.value();
          },
          fetch: (tags, page, {limit, options}) async {
            final posts = await searchNotifier.searchByTags(
              tags,
              page: page,
              limit: limit,
            );
            return posts.toResult();
          },
          fetchFromController: (controller, page, {limit, options}) async {
            final posts = await searchNotifier.searchByController(
              controller,
              page: page,
              limit: limit,
            );
            return posts.toResult();
          },
        );
      },
    );
