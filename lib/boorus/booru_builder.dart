// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/gelbooru_v1/gelbooru_v1.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/boorus/sankaku/sankaku.dart';
import 'package:boorusama/boorus/zerochan/zerochan.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'anime-pictures/anime_pictures.dart';
import 'danbooru/posts/posts.dart';
import 'gelbooru_v2/gelbooru_v2.dart';
import 'hydrus/hydrus.dart';
import 'philomena/philomena.dart';
import 'shimmie2/shimmie2.dart';
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

  QuickFavoriteButtonBuilder? get quickFavoriteButtonBuilder;

  HomeViewBuilder get homeViewBuilder;

  GridThumbnailUrlBuilder get gridThumbnailUrlBuilder;

  TagColorBuilder get tagColorBuilder;

  DownloadFilenameGenerator get downloadFilenameBuilder;

  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder;

  PostStatisticsPageBuilder get postStatisticsPageBuilder;

  GranularRatingFilterer? get granularRatingFilterer;
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder;

  PostGestureHandlerBuilder get postGestureHandlerBuilder;

  MetatagExtractor? get metatagExtractor;

  MultiSelectionActionsBuilder? get multiSelectionActionsBuilder;

  PostDetailsUIBuilder get postDetailsUIBuilder;

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
          BooruType.zerochan: (config) => ZerochanBuilder(),
          BooruType.moebooru: (config) => MoebooruBuilder(),
          BooruType.gelbooru: (config) => GelbooruBuilder(
                client: () => ref.read(gelbooruClientProvider(config)),
              ),
          BooruType.gelbooruV2: (config) => GelbooruV2Builder(
                client: ref.read(gelbooruV2ClientProvider(config)),
              ),
          BooruType.e621: (config) => E621Builder(),
          BooruType.danbooru: (config) => DanbooruBuilder(
                favoriteRepo: ref.read(danbooruFavoriteRepoProvider(config)),
                postCountRepo: ref.read(danbooruPostCountRepoProvider(config)),
                tagInfo: ref.read(tagInfoProvider),
              ),
          BooruType.gelbooruV1: (config) => GelbooruV1Builder(),
          BooruType.sankaku: (config) => SankakuBuilder(),
          BooruType.philomena: (config) => PhilomenaBuilder(),
          BooruType.shimmie2: (config) => Shimmie2Builder(),
          BooruType.szurubooru: (config) => SzurubooruBuilder(),
          BooruType.hydrus: (config) => HydrusBuilder(),
          BooruType.animePictures: (config) => AnimePicturesBuilder(),
        });
