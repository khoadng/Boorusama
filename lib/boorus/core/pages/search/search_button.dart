// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/search/search.dart';

class SearchButton extends ConsumerWidget {
  const SearchButton({
    super.key,
    this.onSearch,
  });

  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowSearch = ref.watch(allowSearchProvider);

    return allowSearch
        ? FloatingActionButton(
            onPressed: () {
              onSearch?.call();
              ref.read(searchProvider.notifier).search();
            },
            heroTag: null,
            child: const Icon(Icons.search),
          )
        : const SizedBox.shrink();
  }
}
