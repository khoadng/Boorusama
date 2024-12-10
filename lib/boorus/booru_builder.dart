// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../core/boorus.dart';
import '../core/downloads/filename.dart';
import 'anime-pictures/anime_pictures.dart';
import 'booru_builder_types.dart';
import 'danbooru/danbooru.dart';
import 'e621/e621.dart';
import 'gelbooru/gelbooru.dart';
import 'gelbooru_v1/gelbooru_v1.dart';
import 'gelbooru_v2/gelbooru_v2.dart';
import 'hydrus/hydrus.dart';
import 'moebooru/moebooru.dart';
import 'philomena/philomena.dart';
import 'sankaku/sankaku.dart';
import 'shimmie2/shimmie2.dart';
import 'szurubooru/szurubooru.dart';
import 'zerochan/zerochan.dart';

export 'booru_builder_extensions.dart';

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
