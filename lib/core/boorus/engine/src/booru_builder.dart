// Project imports:
import '../../../home/custom_home.dart';
import 'booru_builder_types.dart';

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

  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder;

  PostStatisticsPageBuilder get postStatisticsPageBuilder;

  GranularRatingFilterer? get granularRatingFilterer;
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder;

  PostGestureHandlerBuilder get postGestureHandlerBuilder;

  MetatagExtractorBuilder? get metatagExtractorBuilder;

  TagSuggestionItemBuilder get tagSuggestionItemBuilder;

  MultiSelectionActionsBuilder? get multiSelectionActionsBuilder;

  Map<CustomHomeViewKey, CustomHomeDataBuilder> get customHomeViewBuilders;

  PostDetailsUIBuilder get postDetailsUIBuilder;

  ViewTagListBuilder get viewTagListBuilder;

  CreateUnknownBooruWidgetsBuilder get unknownBooruWidgetsBuilder;
}

extension BooruBuilderFeatureCheck on BooruBuilder {
  bool get isArtistSupported => artistPageBuilder != null;
}
