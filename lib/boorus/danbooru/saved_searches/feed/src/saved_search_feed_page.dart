// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../../core/configs/auth/widgets.dart';
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../saved_search/providers.dart';
import 'views/saved_search_feed_content_view.dart';
import 'views/saved_search_landing_view.dart';

class SavedSearchFeedPage extends ConsumerWidget {
  const SavedSearchFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return BooruConfigAuthFailsafe(
      builder: (_) => ref
          .watch(danbooruSavedSearchesProvider(config))
          .when(
            data: (searches) => searches.isNotEmpty
                ? SavedSearchFeedContentView(
                    searches: searches,
                  )
                : const SavedSearchLandingView(),
            error: (error, stackTrace) => const Scaffold(
              body: ErrorBox(),
            ),
            loading: () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          ),
    );
  }
}
