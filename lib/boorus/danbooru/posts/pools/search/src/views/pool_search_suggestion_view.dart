// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../../core/foundation/debounce_mixin.dart';
import '../../../../../../../core/tags/tag/colors.dart';
import '../../../../../../../core/theme.dart';
import '../../../pool/pool.dart';
import '../providers.dart';

class PoolSearchSuggestionView extends ConsumerWidget {
  const PoolSearchSuggestionView({
    required this.textEditingController,
    super.key,
  });

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DebounceText(
      controller: textEditingController,
      debounceKey: 'pool_search',
      builder: (context, query) {
        if (query.isEmpty) {
          return const SizedBox.shrink();
        }

        return ref.watch(poolSuggestionsProvider(query)).maybeWhen(
              data: (pools) => pools.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      itemCount: pools.length,
                      itemBuilder: (context, index) {
                        final pool = pools[index];

                        return ListTile(
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            pool.name.replaceAll('_', ' '),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _poolCategoryToColor(pool.category),
                            ),
                          ),
                          trailing: Text(
                            NumberFormat.compact().format(pool.postCount),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.hintColor,
                            ),
                          ),
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            textEditingController.text =
                                pool.name.replaceAll('_', ' ');
                            ref.read(danbooruPoolQueryProvider.notifier).state =
                                pool.name;
                            ref
                                .read(danbooruPoolSearchModeProvider.notifier)
                                .state = PoolSearchMode.result;
                          },
                        );
                      },
                    ),
              orElse: () => const SizedBox.shrink(),
            );
      },
    );
  }
}

Color _poolCategoryToColor(DanbooruPoolCategory category) => switch (category) {
      DanbooruPoolCategory.series => TagColors.dark().copyright,
      _ => TagColors.dark().general,
    };
