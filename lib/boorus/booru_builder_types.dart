part of 'booru_builder.dart';

typedef CreateConfigPageBuilder = Widget Function(
  BuildContext context,
  String url,
  BooruType booruType, {
  Color? backgroundColor,
});

typedef UpdateConfigPageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config, {
  Color? backgroundColor,
  String? initialTab,
});

typedef HomePageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config,
);

typedef SearchPageBuilder = Widget Function(
  BuildContext context,
  String? initialQuery,
);

typedef PostDetailsPageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config,
  DetailsPayload payload,
);

typedef FavoritesPageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config,
);

typedef QuickFavoriteButtonBuilder = Widget Function(
  BuildContext context,
  Post post,
);

typedef MultiSelectionActionsBuilder = Widget Function(
  BuildContext context,
  MultiSelectController<Post> controller,
);

typedef ArtistPageBuilder = Widget Function(
  BuildContext context,
  String artistName,
);

typedef CharacterPageBuilder = Widget Function(
  BuildContext context,
  String characterName,
);

typedef CommentPageBuilder = Widget Function(
  BuildContext context,
  bool useAppBar,
  int postId,
);

typedef PostFetcher = PostsOrError Function(
  int page,
  String tags,
);

typedef NoteFetcher = Future<List<Note>> Function(int postId);

typedef FavoriteAdder = Future<bool> Function(int postId, WidgetRef ref);
typedef FavoriteRemover = Future<bool> Function(int postId, WidgetRef ref);

typedef GranularRatingFilterer = bool Function(Post post, BooruConfig config);
typedef GranularRatingQueryBuilder = List<String> Function(
  List<String> currentQuery,
  BooruConfig config,
);

typedef GranularRatingOptionsBuilder = Set<Rating> Function();

typedef PostCountFetcher = Future<int?> Function(
  BooruConfig config,
  List<String> tags,
  TagQueryComposer tagQueryComposer,
);

typedef GridThumbnailUrlBuilder = String Function(
  ImageQuality imageQuality,
  Post post,
);

typedef TagColorBuilder = Color? Function(
  Brightness brightness,
  String? tagType,
);

typedef PostImageDetailsUrlBuilder = String Function(
  ImageQuality imageQuality,
  Post post,
  BooruConfig config,
);

typedef PostStatisticsPageBuilder = Widget Function(
  BuildContext context,
  Iterable<Post> posts,
);

typedef PostGestureHandlerBuilder = bool Function(
  WidgetRef ref,
  String? action,
  Post post,
);

typedef HomeViewBuilder = Widget Function(
  BuildContext context,
  BooruConfig config,
  HomePageController controller,
);
