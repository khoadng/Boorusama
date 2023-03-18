// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_feed_bloc.dart';
import 'package:boorusama/core/application/app_rating.dart';
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
