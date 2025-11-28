// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../configs/config/types.dart';
import '../../../configs/create/create.dart';
import '../../../images/types.dart';
import '../../../posts/details/routes.dart';
import '../../../posts/listing/providers.dart';
import '../../../posts/position/types.dart';
import '../../../posts/post/types.dart';
import '../../../search/search/routes.dart';
import '../../../tags/autocompletes/types.dart';
import '../../../tags/tag/colors.dart';

typedef CreateConfigPageBuilder =
    Widget Function(
      BuildContext context,
      EditBooruConfigId id, {
      Color? backgroundColor,
    });

typedef UpdateConfigPageBuilder =
    Widget Function(
      BuildContext context,
      EditBooruConfigId id, {
      Color? backgroundColor,
      String? initialTab,
    });

typedef HomePageBuilder =
    Widget Function(
      BuildContext context,
    );

typedef SearchPageBuilder =
    Widget Function(
      BuildContext context,
      SearchParams params,
    );

typedef PostDetailsPageBuilder =
    Widget Function(
      BuildContext context,
      DetailsRouteContext detailsContext,
    );

typedef FavoritesPageBuilder =
    Widget Function(
      BuildContext context,
    );

typedef QuickFavoriteButtonBuilder =
    Widget Function(
      BuildContext context,
      Post post,
    );

typedef MultiSelectionActionsBuilder =
    Widget Function(
      BuildContext context,
      SelectionModeController controller,
      PostGridController<Post> postController,
    );

typedef ArtistPageBuilder =
    Widget Function(
      BuildContext context,
      String artistName,
    );

typedef CharacterPageBuilder =
    Widget Function(
      BuildContext context,
      String characterName,
    );

typedef CommentPageBuilder =
    Widget Function(
      BuildContext context,
      bool useAppBar,
      Post post,
    );

typedef GranularRatingFilterer =
    bool Function(
      Post post,
      BooruConfigSearch config,
    );
typedef GranularRatingQueryBuilder =
    List<String> Function(
      List<String> currentQuery,
      BooruConfigSearch config,
    );

typedef TagColorBuilder =
    Color? Function(
      TagColorOptions options,
    );

typedef TagColorsBuilder =
    TagColors Function(
      TagColorsOptions options,
    );

typedef PostImageDetailsUrlBuilder =
    String Function(
      ImageQuality imageQuality,
      Post post,
      BooruConfigViewer config,
    );

typedef PostStatisticsPageBuilder =
    Widget Function(
      BuildContext context,
      Iterable<Post> posts,
    );

typedef PostGestureHandlerBuilder =
    bool Function(
      WidgetRef ref,
      String? action,
      Post post,
    );

typedef TagSuggestionItemBuilder =
    Widget Function(
      BooruConfigAuth config,
      AutocompleteData tag,
      bool dense,
      String currentQuery,
      ValueChanged<AutocompleteData> onItemTap,
    );

typedef HomeViewBuilder =
    Widget Function(
      BuildContext context,
    );

typedef ViewTagListBuilder =
    Widget Function(
      BuildContext context,
      Post post,
      bool initiallyMultiSelectEnabled,
      BooruConfigAuth auth,
    );

typedef CreateUnknownBooruWidgetsBuilder =
    Widget Function(
      BuildContext context,
    );

typedef VideoQualitySelectionBuilder =
    Widget? Function(
      BuildContext context,
      Post post, {
      void Function(Widget page)? onPushPage,
      void Function()? onPopPage,
    });

typedef SessionRestoreBuilder =
    Widget Function(
      BuildContext context,
      PaginationSnapshot snapshot,
    );
