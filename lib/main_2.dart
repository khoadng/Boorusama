// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/posts/latest_posts_view.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/theme/theme_buider.dart';
import 'package:boorusama/instance.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'boorus/booru_builder.dart';
import 'clients/danbooru/danbooru_client.dart';
import 'foundation/networking/networking.dart';

final currentBooruBuilder = Provider<BooruBuilder>((ref) {
  return DanbooruBuilder();
});

final postRepoProvider = Provider<PostRepository<DanbooruPost>>((ref) {
  throw UnimplementedError();
});

void mainInstance() async {
  print('Running mainInstance');
  final client = AppInstanceClient();

  final session = await client.getSession();

  print('Session: ${session?.toJson()}');

  if (session == null) {
    runApp(const MaterialApp(
        home: Scaffold(body: Center(child: Text('No session found')))));
    return;
  }

  final booruType = session.config.booruType;

  // return if not danbooru
  if (booruType != BooruType.danbooru) {
    runApp(const MaterialApp(
        home: Scaffold(
            body: Center(child: Text('Booru type not supported yet')))));
    return;
  }

  final settings = session.settings;
  final imageListingSettings =
      session.config.listing?.settings ?? settings.listing;
  final booruConfig = session.config;
  final dio = Dio(BaseOptions(
    baseUrl: booruConfig.url,
    headers: {
      AppHttpHeaders.userAgentHeader: 'Boorusama',
    },
  ));

  final booruClient = DanbooruClient(
    dio: dio,
    baseUrl: booruConfig.url,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
  );

  runApp(ProviderScope(
    overrides: [
      imageListingSettingsProvider.overrideWithValue(imageListingSettings),
      settingsProvider.overrideWithValue(settings),
      danbooruClientProvider.overrideWith((ref, config) => booruClient),
      currentReadOnlyBooruConfigProvider.overrideWithValue(booruConfig),
      userAgentGeneratorProvider
          .overrideWith((ref, config) => UserAgentGeneratorImpl(
                appVersion: '1.0.0',
                appName: 'Boorusama',
                config: config,
              )),
    ],
    child: const MyApp(),
  ));
}

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (theme, mode) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Boorusama - Danbooru',
        theme: theme,
        themeMode: mode,
        home: const LatestView(),
      ),
    );
  }
}

class LatestView extends ConsumerStatefulWidget {
  const LatestView({
    super.key,
  });

  @override
  ConsumerState<LatestView> createState() => _LatestViewState();
}

class _LatestViewState extends ConsumerState<LatestView> {
  final _autoScrollController = AutoScrollController();
  final _selectedMostSearchedTag = ValueNotifier('');
  late final selectedTagController = SelectedTagController.fromBooruBuilder(
    builder: ref.read(currentBooruBuilder),
    tagInfo: TagInfo(
      metatags: {},
      defaultBlacklistedTags: {},
      r18Tags: {},
    ),
  );
  final MultiSelectController<DanbooruPost> _multiSelectController =
      MultiSelectController<DanbooruPost>();

  @override
  void dispose() {
    _autoScrollController.dispose();
    _selectedMostSearchedTag.dispose();
    selectedTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;
    final postRepo = ref.watch(danbooruPostRepoProvider(config));
    final settings = ref.watch(imageListingSettingsProvider);

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        return PostScope(
          fetcher: (page) {
            final tag = _selectedMostSearchedTag.value;

            return postRepo.getPosts(tag, page);
          },
          builder: (context, controller, errors) => PostGrid(
            gridHeader: const SizedBox(),
            controller: controller,
            scrollController: _autoScrollController,
            body: SliverPostGrid(
              postController: controller,
              multiSelectController: _multiSelectController,
              constraints: constraints,
              itemBuilder: (context, index, post) {
                final (width, height, cacheWidth, cacheHeight) =
                    context.sizeFromConstraints(
                  constraints,
                  post.aspectRatio,
                );

                return ExplicitContentBlockOverlay(
                  width: width ?? 100,
                  height: height ?? 100,
                  block: settings.blurExplicitMedia && post.isExplicit,
                  childBuilder: (block) => ImageGridItem(
                    isGif: post.isGif,
                    isAI: post.isAI,
                    autoScrollOptions: AutoScrollOptions(
                      controller: _autoScrollController,
                      index: index,
                    ),
                    isAnimated: post.isAnimated,
                    isTranslated: post.isTranslated,
                    hasComments: post.hasComment,
                    hasParentOrChildren: post.hasParentOrChildren,
                    score: settings.showScoresInGrid ? post.score : null,
                    borderRadius: BorderRadius.circular(
                      settings.imageBorderRadius,
                    ),
                    image: BooruImage(
                      aspectRatio: post.aspectRatio,
                      imageUrl: post.thumbnailImageUrl,
                      borderRadius: BorderRadius.circular(
                        settings.imageBorderRadius,
                      ),
                      forceFill:
                          settings.imageListType == ImageListType.standard,
                      placeholderUrl: post.thumbnailImageUrl,
                      width: width,
                      height: height,
                      cacheHeight: cacheHeight,
                      cacheWidth: cacheWidth,
                    ),
                  ),
                );
              },
              error: errors,
            ),
          ),
        );
      }),
    );
  }

  var selectedTagString = ValueNotifier('');
}

typedef PostScopeFetcher<T extends Post> = PostsOrErrorCore<T> Function(
    int page);

class PostScope<T extends Post> extends ConsumerStatefulWidget {
  const PostScope({
    super.key,
    required this.fetcher,
    required this.builder,
  });

  final PostScopeFetcher<T> fetcher;
  final Widget Function(
    BuildContext context,
    PostGridController<T> controller,
    BooruError? errors,
  ) builder;

  @override
  ConsumerState<PostScope<T>> createState() => _PostScopeState();
}

class _PostScopeState<T extends Post> extends ConsumerState<PostScope<T>> {
  late final _controller = PostGridController<T>(
    fetcher: (page) => fetchPosts(page),
    refresher: () => fetchPosts(1),
    blacklistedTagsFetcher: () {
      return Future.value({});
    },
    pageMode: ref
        .read(imageListingSettingsProvider.select((value) => value.pageMode)),
    blacklistedUrlsFetcher: () {
      return {};
    },
    mountedChecker: () => mounted,
  );

  BooruError? errors;

  Future<PostResult<T>> fetchPosts(int page) {
    if (errors != null) {
      setState(() {
        errors = null;
      });
    }

    return widget.fetcher(page).run().then((value) => value.fold(
          (l) {
            if (mounted) {
              setState(() => errors = l);
            }
            return <T>[].toResult();
          },
          (r) => r,
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      imageListingSettingsProvider.select((value) => value.pageMode),
      (previous, next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _controller.setPageMode(next);
        });
      },
    );

    return widget.builder(
      context,
      _controller,
      errors,
    );
  }
}
