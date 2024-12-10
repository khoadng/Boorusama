// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/failsafe.dart';
import '../../../../../core/configs/ref.dart';
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
      child: CustomContextMenuOverlay(
        child: ref.watch(danbooruSavedSearchesProvider(config)).when(
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
      ),
    );
  }
}
