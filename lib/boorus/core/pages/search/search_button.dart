// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchButton extends ConsumerWidget {
  const SearchButton({
    super.key,
    required this.onSearch,
    required this.allowSearch,
  });

  final VoidCallback onSearch;
  final bool allowSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return allowSearch
        ? FloatingActionButton(
            onPressed: onSearch,
            heroTag: null,
            child: const Icon(Icons.search),
          )
        : const SizedBox.shrink();
  }
}
