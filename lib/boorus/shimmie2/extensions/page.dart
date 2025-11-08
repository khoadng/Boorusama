// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/themes/theme/types.dart';
import '../../../core/widgets/booru_version_chip.dart';
import '../../../core/widgets/widgets.dart';
import 'providers.dart';
import 'widgets.dart';

class Shimmie2ExtensionsPage extends ConsumerWidget {
  const Shimmie2ExtensionsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final extensionsState = ref.watch(shimmie2ExtensionsProvider(config.url));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                context.t.shimmie2.extension.title,
              ),
            ),
            switch (extensionsState) {
              AsyncData(:final value) => switch (value) {
                Shimmie2ExtensionsData(:final version?) => BooruVersionChip(
                  version: version,
                ),
                _ => const SizedBox.shrink(),
              },
              _ => const SizedBox.shrink(),
            },
          ],
        ),
        actions: [
          ExtensionRefreshButton(
            isLoading: extensionsState.isLoading,
            onPressed: () {
              ref
                  .read(shimmie2ExtensionsProvider(config.url).notifier)
                  .refresh();
            },
          ),
        ],
      ),
      body: extensionsState.when(
        data: (state) => switch (state) {
          Shimmie2ExtensionsData(:final extensions) when extensions.isEmpty =>
            const Center(child: NoDataBox()),
          Shimmie2ExtensionsData() => _ExtensionsList(state: state),
          Shimmie2ExtensionsNotSupported() => Center(
            child: Text(context.t.shimmie2.extension.failed_to_fetch),
          ),
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _ExtensionsList extends StatelessWidget {
  const _ExtensionsList({
    required this.state,
  });

  final Shimmie2ExtensionsData state;

  @override
  Widget build(BuildContext context) {
    final grouped = state.getAllByCategory();
    final categories = state.getCategoriesSorted();
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          children: [
            if (state.lastUpdateTimestamp case final timestamp?)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${context.t.comment.list.last_updated}: ${timestamp.fuzzify(locale: Localizations.localeOf(context))}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.hintColor,
                  ),
                ),
              ),
            ...categories.map((category) {
              return ExtensionCategorySection(
                category: category,
                extensions: grouped[category] ?? [],
              );
            }),
          ],
        ),
      ),
    );
  }
}
