// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/pages/artists/gelbooru_artist_page.dart';
import 'package:boorusama/boorus/gelbooru/pages/posts.dart';
import 'package:boorusama/boorus/gelbooru/pages/search/gelbooru_search_page.dart';
import 'package:boorusama/flutter.dart';

void goToGelbooruPostDetailsPage({
  required WidgetRef ref,
  required BuildContext context,
  required Settings settings,
  required List<Post> posts,
  required int initialIndex,
  AutoScrollController? scrollController,
}) {
  final booru = ref.read(currentBooruProvider);
  context.navigator.push(GelbooruPostDetailPage.routeOf(
    booru: booru,
    posts: posts,
    initialIndex: initialIndex,
    scrollController: scrollController,
    settings: settings,
  ));
}

void goToGelbooruSearchPage(
  WidgetRef ref,
  BuildContext context, {
  String? tag,
}) =>
    context.navigator.push(GelbooruSearchPage.routeOf(ref, context, tag: tag));

void goToGelbooruArtistPage(
  WidgetRef ref,
  BuildContext context,
  String artist,
) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => provideArtistPageDependencies(
      ref,
      artist: artist,
      page: GelbooruArtistPage(
        tagName: artist,
      ),
    ),
  ));
}

Widget provideArtistPageDependencies(
  WidgetRef ref, {
  required String artist,
  required Widget page,
}) {
  return GelbooruProvider(
    builder: (_) {
      return CustomContextMenuOverlay(
        child: page,
      );
    },
  );
}
