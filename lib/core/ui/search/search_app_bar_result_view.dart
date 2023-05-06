// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/ui/search/selected_tag_list_with_data.dart';
import 'package:boorusama/core/ui/search_bar.dart';

class SearchAppBarResultView extends ConsumerWidget {
  const SearchAppBarResultView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      titleSpacing: 0,
      toolbarHeight: kToolbarHeight * 1.9,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      title: SizedBox(
        height: kToolbarHeight * 1.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBar(
                enabled: false,
                onTap: () =>
                    ref.read(searchProvider.notifier).goToSuggestions(),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () =>
                      ref.read(searchProvider.notifier).resetToOptions(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const SelectedTagListWithData(),
          ],
        ),
      ),
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
    );
  }
}
