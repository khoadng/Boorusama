// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:context_menus/context_menus.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/downloads/bulk_image_download_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/downloads/bulk_post_download_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_feed_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/user/current_user_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_count_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/services/bulk_downloader.dart';
import 'package:boorusama/boorus/danbooru/ui/features/blacklisted_tags/blacklisted_tags_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/downloads/bulk_download_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/favorites/favorite_group_details_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/favorites/favorite_groups_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/pool/pool_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/settings_page.dart';
import 'package:boorusama/core/application/app_rating.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'router.dart';
import 'ui/features/home/home_page_2.dart';
import 'ui/features/home/home_page_desktop.dart';
import 'ui/features/saved_search/saved_search_feed_page.dart';
import 'ui/features/saved_search/saved_search_page.dart';

final rootHandler = Handler(
  handlerFunc: (context, parameters) => ConditionalParentWidget(
    condition: canRate(),
    conditionalBuilder: (child) => createAppRatingWidget(child: child),
    child: CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.keyF,
          control: true,
        ): () => goToSearchPage(context!),
      },
      child: CustomContextMenuOverlay(
        child: Focus(
          autofocus: true,
          child:
              isMobilePlatform() ? const HomePage2() : const HomePageDesktop(),
        ),
      ),
    ),
  ),
);

class CustomContextMenuOverlay extends StatelessWidget {
  const CustomContextMenuOverlay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ContextMenuOverlay(
      cardBuilder: (context, children) => Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(children: children),
        ),
      ),
      buttonBuilder: (context, config, [__]) => ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            child: ListTile(
              dense: true,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              hoverColor: Theme.of(context).colorScheme.primary,
              onTap: config.onPressed,
              title: Text(config.label),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              minVerticalPadding: 0,
            ),
          ),
        ),
      ),
      child: child,
    );
  }
}

final settingsHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  return const SettingsPage();
});

final poolDetailHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  final args = context!.settings!.arguments as List;
  final pool = args.first as Pool;

  return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
    builder: (context, state) {
      final booru = state.booru ?? safebooru();

      return MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: PoolDescriptionBloc(
              endpoint: booru.url,
              poolDescriptionRepository:
                  context.read<PoolDescriptionRepository>(),
            )..add(PoolDescriptionFetched(poolId: pool.id)),
          ),
          BlocProvider(
            create: (context) => PostBloc.of(context)
              ..add(
                PostRefreshed(
                  fetcher: PoolPostFetcher(
                    postIds: pool.postIds.reversed.take(20).toList(),
                  ),
                ),
              ),
          ),
        ],
        child: CustomContextMenuOverlay(
          child: PoolDetailPage(
            pool: pool,
            // https://github.com/dart-code-checker/dart-code-metrics/issues/1046
            // ignore: prefer-iterable-of
            postIds: QueueList.from(pool.postIds.reversed.skip(20)),
          ),
        ),
      );
    },
  );
});

final favoriteGroupsHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  return BlocBuilder<CurrentUserBloc, CurrentUserState>(
    builder: (context, state) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => FavoriteGroupsBloc.of(
              context,
              currentUser: state.user,
            )..add(const FavoriteGroupsRefreshed(includePreviews: true)),
          ),
        ],
        child: const FavoriteGroupsPage(),
      );
    },
  );
});

final favoriteGroupDetailsHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  final args = context!.settings!.arguments as List;

  final FavoriteGroup group = args.first;
  final FavoriteGroupsBloc bloc = args[1];

  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => PostBloc.of(context)
          ..add(PostRefreshed(
            fetcher:
                FavoriteGroupPostFetcher(ids: group.postIds.take(60).toList()),
          )),
      ),
      BlocProvider.value(value: bloc),
    ],
    child: CustomContextMenuOverlay(
      child: FavoriteGroupDetailsPage(
        group: group,
        postIds: QueueList.from(group.postIds.skip(60)),
      ),
    ),
  );
});

final blacklistedTagsHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(
        value: BlocProvider.of<BlacklistedTagsBloc>(context!)
          ..add(const BlacklistedTagRequested()),
      ),
    ],
    child: const BlacklistedTagsPage(),
  );
});

final bulkDownloadHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  final args = context!.settings!.arguments as List;
  final List<String>? initialSelectedTags = args.isNotEmpty ? args.first : null;

  final bulkPostDownloadBloc = BulkPostDownloadBloc(
    downloader: context.read<BulkDownloader<Post>>(),
    postCountRepository: context.read<PostCountRepository>(),
    postRepository: context.read<PostRepository>(),
    errorTranslator: getErrorMessage,
    onDownloadDone: (path) => MediaScanner.loadMedia(path: path),
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => BulkImageDownloadBloc(
          permissionChecker: () => Permission.storage.status,
          permissionRequester: () => Permission.storage.request(),
          bulkPostDownloadBloc: bulkPostDownloadBloc,
        )..add(BulkImageDownloadTagsAdded(tags: initialSelectedTags)),
      ),
    ],
    child: const BulkDownloadPage(),
  );
});

final savedSearchHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => PostBloc.of(context),
      ),
      BlocProvider(
        create: (context) => SavedSearchFeedBloc(
          savedSearchBloc: context.read<SavedSearchBloc>(),
        )..add(const SavedSearchFeedRefreshed()),
      ),
    ],
    child: const CustomContextMenuOverlay(child: SavedSearchFeedPage()),
  );
});

final savedSearchEditHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(
        value: context!.read<SavedSearchBloc>()
          ..add(const SavedSearchFetched()),
      ),
    ],
    child: const SavedSearchPage(),
  );
});
