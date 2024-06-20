// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/gelbooru_v1/gelbooru_v1.dart';
import 'package:boorusama/boorus/gelbooru_v2/posts/posts_v2.dart';
import 'package:boorusama/boorus/moebooru/feats/autocomplete/moebooru_autocomplete_provider.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/boorus/sankaku/sankaku.dart';
import 'package:boorusama/boorus/shimmie2/providers.dart';
import 'package:boorusama/boorus/zerochan/zerochan.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/core/configs/manage/providers.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/pages/post_statistics_page.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/routes.dart';
import 'danbooru/feats/notes/notes.dart';
import 'danbooru/feats/posts/posts.dart';
import 'e621/feats/notes/notes.dart';
import 'gelbooru_v2/gelbooru_v2.dart';
import 'philomena/philomena.dart';
import 'philomena/providers.dart';
import 'shimmie2/shimmie2.dart';
import 'szurubooru/providers.dart';
import 'szurubooru/szurubooru.dart';

part 'booru_builder_types.dart';
part 'booru_builder_default.dart';
part 'booru_builder_extensions.dart';

abstract class BooruBuilder {
  // UI Builders
  HomePageBuilder get homePageBuilder;
  CreateConfigPageBuilder get createConfigPageBuilder;
  UpdateConfigPageBuilder get updateConfigPageBuilder;
  SearchPageBuilder get searchPageBuilder;
  PostDetailsPageBuilder get postDetailsPageBuilder;
  FavoritesPageBuilder? get favoritesPageBuilder;
  ArtistPageBuilder? get artistPageBuilder;
  CharacterPageBuilder? get characterPageBuilder;
  CommentPageBuilder? get commentPageBuilder;

  HomeViewBuilder get homeViewBuilder;

  GridThumbnailUrlBuilder get gridThumbnailUrlBuilder;

  TagColorBuilder get tagColorBuilder;

  DownloadFilenameGenerator get downloadFilenameBuilder;

  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder;

  PostStatisticsPageBuilder get postStatisticsPageBuilder;

  GranularRatingFilterer? get granularRatingFilterer;
  GranularRatingQueryBuilder? get granularRatingQueryBuilder;
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder;

  PostGestureHandlerBuilder get postGestureHandlerBuilder;

  // Data Builders
  PostFetcher get postFetcher;
  AutocompleteFetcher get autocompleteFetcher;
  NoteFetcher? get noteFetcher;

  // Action Builders
  FavoriteAdder? get favoriteAdder;
  FavoriteRemover? get favoriteRemover;

  PostCountFetcher? get postCountFetcher;
}

/// A provider that provides a map of [BooruType] to [BooruBuilder] functions
/// that can be used to build a Booru instances with the given [BooruConfig].
///
/// The [BooruType] enum represents different types of boorus that can be built.
/// The [BooruConfig] class represents the configuration for a booru instance.
///
/// Example usage:
/// ```
/// final booruBuildersProvider = Provider<Map<BooruType, BooruBuilder Function(BooruConfig config)>>((ref) =>
///   {
///     BooruType.zerochan: (config) => ZerochanBuilder(
///       postRepo: ref.watch(zerochanPostRepoProvider(config)),
///       autocompleteRepo: ref.watch(zerochanAutoCompleteRepoProvider(config)),
///     ),
///     // ...
///   }
/// );
/// ```
/// Note that the [BooruBuilder] functions are not called until they are used and they won't be called again
/// Each local instance of [BooruBuilder] will be cached and reused until the app is restarted.
final booruBuildersProvider =
    Provider<Map<BooruType, BooruBuilder Function(BooruConfig config)>>((ref) =>
        {
          BooruType.zerochan: (config) => ZerochanBuilder(
                postRepo: ref.read(zerochanPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(zerochanAutoCompleteRepoProvider(config)),
              ),
          BooruType.moebooru: (config) => MoebooruBuilder(
                postRepo: ref.read(moebooruPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(moebooruAutocompleteRepoProvider(config)),
              ),
          BooruType.gelbooru: (config) => GelbooruBuilder(
                postRepo: ref.read(gelbooruPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(gelbooruAutocompleteRepoProvider(config)),
                noteRepo: ref.read(gelbooruNoteRepoProvider(config)),
                client: () => ref.read(gelbooruClientProvider(config)),
              ),
          BooruType.gelbooruV2: (config) => GelbooruV2Builder(
                postRepo: ref.read(gelbooruV2PostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(gelbooruV2AutocompleteRepoProvider(config)),
                noteRepo: ref.read(gelbooruV2NoteRepoProvider(config)),
                client: ref.read(gelbooruV2ClientProvider(config)),
              ),
          BooruType.e621: (config) => E621Builder(
                autocompleteRepo:
                    ref.read(e621AutocompleteRepoProvider(config)),
                postRepo: ref.read(e621PostRepoProvider(config)),
                noteRepo: ref.read(e621NoteRepoProvider(config)),
              ),
          BooruType.danbooru: (config) => DanbooruBuilder(
                postRepo: ref.read(danbooruPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(danbooruAutocompleteRepoProvider(config)),
                favoriteRepo: ref.read(danbooruFavoriteRepoProvider(config)),
                postCountRepo: ref.read(danbooruPostCountRepoProvider(config)),
                noteRepo: ref.read(danbooruNoteRepoProvider(config)),
              ),
          BooruType.gelbooruV1: (config) => GelbooruV1Builder(
                postRepo: ref.read(gelbooruV1PostRepoProvider(config)),
                client: GelbooruClient.gelbooru(),
              ),
          BooruType.sankaku: (config) => SankakuBuilder(
                postRepository: ref.read(sankakuPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(sankakuAutocompleteRepoProvider(config)),
              ),
          BooruType.philomena: (config) => PhilomenaBuilder(
                postRepo: ref.read(philomenaPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(philomenaAutoCompleteRepoProvider(config)),
              ),
          BooruType.shimmie2: (config) => Shimmie2Builder(
                postRepo: ref.read(shimmie2PostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(shimmie2AutocompleteRepoProvider(config)),
              ),
          BooruType.szurubooru: (config) => SzurubooruBuilder(
                postRepo: ref.read(szurubooruPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(szurubooruAutocompleteRepoProvider(config)),
              ),
        });

class BooruProvider extends ConsumerWidget {
  const BooruProvider({
    super.key,
    required this.builder,
  });

  final Widget Function(BooruBuilder? booruBuilderl, WidgetRef ref) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider);

    return builder(booruBuilder, ref);
  }
}
