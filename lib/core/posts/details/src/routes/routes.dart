// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../configs/config.dart';
import '../../../../router.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/post.dart';
import '../providers/providers.dart';
import '../widgets/post_details_page.dart';
import 'details_route_context.dart';

GoRoute postDetailsRoutes(Ref ref) => GoRoute(
  path: 'details',
  name: '/details',
  pageBuilder: (context, state) {
    final context = castOrNull<DetailsRouteContext>(state.extra);
    final settings = ref.read(settingsProvider);

    if (context == null) {
      return MaterialPage(
        child: InvalidPage(message: 'Invalid context: $context'),
      );
    }

    final widget = InheritedDetailsContext(
      context: context,
      child: const CurrentPostDetailsPage(),
    );

    return _detailsPageBuilder(
      context.isDesktop,
      context.hero,
      settings,
      state,
      widget,
    );
  },
);

GoRoute singlePostDetailsRoutes(Ref ref) => GoRoute(
  path: 'posts/:id',
  name: '/posts',
  pageBuilder: (_, state) {
    final context = castOrNull<DetailsRouteContext>(state.extra);
    final configSearch = context?.configSearch;

    final postIdString = state.pathParameters['id'];
    final settings = ref.read(settingsProvider);
    final postId = postIdString != null ? PostId.from(postIdString) : null;

    if (postId == null || configSearch == null) {
      return MaterialPage(
        child: InvalidPage(message: 'Invalid post Id: $postId'),
      );
    }

    final widget = PostDetailsDataLoadingTransitionPage(
      postId: postId,
      configSearch: configSearch,
      pageBuilder: (context, detailsContext) {
        final widget = InheritedDetailsContext(
          context: detailsContext,
          child: const PayloadPostDetailsPage(),
        );

        return widget;
      },
    );

    return _detailsPageBuilder(
      context?.isDesktop ?? false,
      context?.hero ?? false,
      settings,
      state,
      widget,
    );
  },
);

Page<dynamic> _detailsPageBuilder(
  bool isDesktop,
  bool useHero,
  Settings settings,
  GoRouterState state,
  Widget widget,
) {
  final hero = kEnableHeroTransition && useHero;

  // must use the value from the payload for orientation
  // Using MediaQuery.orientationOf(context) will cause the page to be rebuilt
  return !isDesktop
      ? hero && !settings.reduceAnimations
            ? PostDetailsHeroPage(
                key: state.pageKey,
                name: state.name,
                child: widget,
              )
            : MaterialPage(
                key: state.pageKey,
                name: state.name,
                child: widget,
              )
      : hero && !settings.reduceAnimations
      ? PostDetailsHeroPage(
          key: state.pageKey,
          name: state.name,
          child: widget,
        )
      : FastFadePage(
          key: state.pageKey,
          name: state.name,
          child: widget,
        );
}

class PostDetailsDataLoadingTransitionPage extends ConsumerWidget {
  const PostDetailsDataLoadingTransitionPage({
    required this.pageBuilder,
    required this.postId,
    required this.configSearch,
    super.key,
  });

  final PostId postId;
  final BooruConfigSearch configSearch;

  final Widget Function(
    BuildContext context,
    DetailsRouteContext<Post> detailsContext,
  )
  pageBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (postId, configSearch);
    return ref
        .watch(singlePostDetailsProvider(params))
        .when(
          data: (post) {
            if (post == null) {
              return InvalidPage(message: 'Invalid post: $post');
            }

            final detailsContext = DetailsRouteContext(
              initialIndex: 0,
              posts: [post],
              scrollController: null,
              isDesktop: false,
              hero: false,
              initialThumbnailUrl: null,
              dislclaimer: 'Single post mode, swiping is disabled',
              configSearch: configSearch,
            );
            return pageBuilder(context, detailsContext);
          },
          error: (error, stackTrace) => InvalidPage(message: error.toString()),
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
  }
}

class PostDetailsHeroPage<T> extends CustomTransitionPage<T> {
  PostDetailsHeroPage({
    required super.child,
    super.name,
    super.key,
  }) : super(
         transitionDuration: const Duration(milliseconds: 200),
         reverseTransitionDuration: const Duration(milliseconds: 200),
         transitionsBuilder: postDetailsTransitionBuilder(),
       );
}

RouteTransitionsBuilder postDetailsTransitionBuilder() =>
    (context, animation, secondaryAnimation, child) => FadeTransition(
      opacity:
          Tween<double>(
            begin: 0,
            end: 1,
          ).animate(
            animation.status == AnimationStatus.reverse
                ? CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInQuint,
                  )
                : CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutQuint,
                  ),
          ),
      child: child,
    );
