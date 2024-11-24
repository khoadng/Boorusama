// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
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

  MetatagExtractorBuilder? get metatagExtractorBuilder;

  MultiSelectionActionsBuilder? get multiSelectionActionsBuilder;

  PostDetailsUIBuilder get postDetailsUIBuilder;
}

/// A provider that provides a map of [BooruType] to [BooruBuilder] functions
/// that can be used to build a Booru instances.
///
/// The [BooruType] enum represents different types of boorus that can be built.
///
/// Example usage:
/// ```
/// final booruBuildersProvider = Provider<Map<BooruType, BooruBuilder Function()>>((ref) =>
///   {
///     BooruType.zerochan: () => ZerochanBuilder(),
///     // ...
///   }
/// );
/// ```
/// Note that the [BooruBuilder] functions are not called until they are used and they won't be called again
/// Each local instance of [BooruBuilder] will be cached and reused until the app is restarted.
final booruBuildersProvider = Provider<Map<BooruType, BooruBuilder Function()>>(
  (ref) => {
    BooruType.zerochan: () => ZerochanBuilder(),
    BooruType.moebooru: () => MoebooruBuilder(),
    BooruType.gelbooru: () => GelbooruBuilder(),
    BooruType.gelbooruV2: () => GelbooruV2Builder(),
    BooruType.e621: () => E621Builder(),
    BooruType.danbooru: () => DanbooruBuilder(),
    BooruType.gelbooruV1: () => GelbooruV1Builder(),
    BooruType.sankaku: () => SankakuBuilder(),
    BooruType.philomena: () => PhilomenaBuilder(),
    BooruType.shimmie2: () => Shimmie2Builder(),
    BooruType.szurubooru: () => SzurubooruBuilder(),
    BooruType.hydrus: () => HydrusBuilder(),
    BooruType.animePictures: () => AnimePicturesBuilder(),
  },
);
