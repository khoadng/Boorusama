// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/ui/artists/gelbooru_artist_page.dart';
import 'package:boorusama/boorus/gelbooru/ui/posts.dart';
import 'package:boorusama/boorus/gelbooru/ui/search/gelbooru_search_page.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';

void goToGelbooruPostDetailsPage({
  required BuildContext context,
  required Settings settings,
  required List<Post> posts,
  required int initialIndex,
  AutoScrollController? scrollController,
}) {
  Navigator.of(context).push(GelbooruPostDetailPage.routeOf(
    context,
    posts: posts,
    initialIndex: initialIndex,
    scrollController: scrollController,
    settings: settings,
  ));
}

void goToGelbooruSearchPage(
  BuildContext context, {
  String? tag,
}) =>
    Navigator.of(context).push(GelbooruSearchPage.routeOf(context, tag: tag));

void goToGelbooruArtistPage(BuildContext context, String artist) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => provideArtistPageDependencies(
      context,
      artist: artist,
      page: GelbooruArtistPage(
        tagName: artist,
      ),
    ),
  ));
}

Widget provideArtistPageDependencies(
  BuildContext context, {
  required String artist,
  required Widget page,
}) {
  return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
    builder: (_, state) {
      return GelbooruProvider.of(
        context,
        booru: state.booru!,
        builder: (dcontext) {
          return CustomContextMenuOverlay(
            child: page,
          );
        },
      );
    },
  );
}
