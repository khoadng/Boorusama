// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/ui/search_bar.dart';

class SearchAppBarResultView extends ConsumerWidget {
  const SearchAppBarResultView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      titleSpacing: 0,
      toolbarHeight: kToolbarHeight * 1.2,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BooruSearchBar(
          enabled: false,
          onTap: () => ref.read(searchProvider.notifier).goToSuggestions(),
          leading: IconButton(
            splashRadius: 16,
            icon: const Icon(Icons.arrow_back),
            onPressed: () => ref.read(searchProvider.notifier).resetToOptions(),
          ),
        ),
      ),
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
    );
  }
}
