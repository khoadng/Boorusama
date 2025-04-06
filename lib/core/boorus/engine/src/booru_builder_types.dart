// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../autocompletes/autocompletes.dart';
import '../../../configs/config.dart';
import '../../../notes/notes.dart';
import '../../../posts/details/routes.dart';
import '../../../posts/details_manager/types.dart';
import '../../../posts/post/post.dart';
import '../../../posts/rating/rating.dart';
import '../../../search/search/src/pages/search_page.dart';
import '../../../settings/settings.dart';
import '../../../tags/configs/configs.dart';
import '../../../tags/metatag/metatag.dart';
import '../../../tags/tag/colors.dart';

typedef CreateConfigPageBuilder = Widget Function(
  BuildContext context,
  EditBooruConfigId id, {
  Color? backgroundColor,
});

typedef UpdateConfigPageBuilder = Widget Function(
  BuildContext context,
  EditBooruConfigId id, {
  Color? backgroundColor,
  String? initialTab,
});

typedef HomePageBuilder = Widget Function(
  BuildContext context,
);

typedef SearchPageBuilder = Widget Function(
  BuildContext context,
  SearchParams params,
);

typedef PostDetailsPageBuilder = Widget Function(
  BuildContext context,
  DetailsRouteContext detailsContext,
);

typedef FavoritesPageBuilder = Widget Function(
  BuildContext context,
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

typedef NoteFetcher = Future<List<Note>> Function(int postId);

typedef FavoriteAdder = Future<bool> Function(int postId, WidgetRef ref);
typedef FavoriteRemover = Future<bool> Function(int postId, WidgetRef ref);

typedef GranularRatingFilterer = bool Function(
  Post post,
  BooruConfigSearch config,
);
typedef GranularRatingQueryBuilder = List<String> Function(
  List<String> currentQuery,
  BooruConfigSearch config,
);

typedef GranularRatingOptionsBuilder = Set<Rating> Function();

typedef GridThumbnailUrlBuilder = String Function(
  ImageQuality imageQuality,
  Post post,
);

typedef TagColorBuilder = Color? Function(
  TagColorOptions options,
);

typedef TagColorsBuilder = TagColors Function(
  TagColorsOptions options,
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

typedef TagSuggestionItemBuilder = Widget Function(
  BooruConfigAuth config,
  AutocompleteData tag,
  bool dense,
  String currentQuery,
  ValueChanged<AutocompleteData> onItemTap,
);

typedef MetatagExtractorBuilder = MetatagExtractor Function(
  TagInfo tagInfo,
);

typedef HomeViewBuilder = Widget Function(
  BuildContext context,
);

const kDefaultPostDetailsPreviewPart = {
  DetailsPart.info,
  DetailsPart.toolbar,
};

const kDefaultPostDetailsBuildablePreviewPart = {
  DetailsPart.info,
  DetailsPart.toolbar,
  DetailsPart.fileDetails,
};

class PostDetailsUIBuilder {
  const PostDetailsUIBuilder({
    this.preview = const {},
    this.full = const {},
    this.previewAllowedParts = const {
      DetailsPart.fileDetails,
      DetailsPart.source,
    },
  });

  final Set<DetailsPart> previewAllowedParts;

  final Map<DetailsPart, Widget Function(BuildContext context)> preview;
  final Map<DetailsPart, Widget Function(BuildContext context)> full;

  Set<DetailsPart> get buildablePreviewParts {
    // use full widgets, except for the ones that are not allowed
    return {
      ...previewAllowedParts.intersection(full.keys.toSet()),
      ...kDefaultPostDetailsBuildablePreviewPart,
      ...preview.keys.toSet(),
    };
  }

  Widget? buildPart(BuildContext context, DetailsPart part) {
    final builder = full[part];
    if (builder != null) {
      return builder(context);
    }

    return null;
  }
}

class TagColorOptions extends Equatable {
  const TagColorOptions({
    required this.tagType,
    required this.colors,
  });

  final String? tagType;
  final TagColors colors;

  @override
  List<Object?> get props => [
        tagType,
        colors,
      ];
}

class TagColorsOptions extends Equatable {
  const TagColorsOptions({
    required this.brightness,
  });

  final Brightness brightness;

  @override
  List<Object?> get props => [
        brightness,
      ];
}
