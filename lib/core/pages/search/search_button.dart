// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme_utils.dart';

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
            child: const Icon(Symbols.search),
          )
        : const SizedBox.shrink();
  }
}

class SearchButton2 extends StatelessWidget {
  const SearchButton2({
    super.key,
    required this.onTap,
  });

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          child: const Icon(
            Symbols.search,
          ),
        ),
      ),
    );
  }
}
