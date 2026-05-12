// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../core/search/search/widgets.dart';
import '../../../../core/tags/tag/colors.dart';
import '../../../../core/themes/theme/types.dart';
import '../../../../foundation/debounce_mixin.dart';
import '../providers.dart';
import '../types.dart';
import 'pool_grid.dart';

class SzurubooruPoolSearchPage extends ConsumerStatefulWidget {
  const SzurubooruPoolSearchPage({super.key});

  @override
  ConsumerState<SzurubooruPoolSearchPage> createState() =>
      _SzurubooruPoolSearchPageState();
}

class _SzurubooruPoolSearchPageState
    extends ConsumerState<SzurubooruPoolSearchPage> {
  final textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(szurubooruPoolSearchModeProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _SzurubooruPoolSearchBar(controller: textEditingController),
      ),
      body: switch (mode) {
        SzurubooruPoolSearchMode.suggestion => _SzurubooruPoolSuggestionView(
          textEditingController: textEditingController,
        ),
        SzurubooruPoolSearchMode.result => const _SzurubooruPoolResultView(),
      },
    );
  }
}

class _SzurubooruPoolSearchBar extends ConsumerWidget {
  const _SzurubooruPoolSearchBar({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(szurubooruPoolQueryProvider);

    return BooruSearchBar(
      leading: IconButton(
        splashRadius: 16,
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Symbols.arrow_back),
      ),
      controller: controller,
      autofocus: true,
      trailing: query != null && query.isNotEmpty
          ? IconButton(
              onPressed: () {
                controller.clear();
                ref.read(szurubooruPoolQueryProvider.notifier).state = '';
              },
              icon: const Icon(Symbols.close),
            )
          : const SizedBox.shrink(),
      onChanged: (value) =>
          ref.read(szurubooruPoolQueryProvider.notifier).state = value,
      onSubmitted: (value) {
        ref.read(szurubooruPoolSearchModeProvider.notifier).state =
            SzurubooruPoolSearchMode.result;
      },
      hintText: context.t.pool.search.hint,
      onTap: () => ref.read(szurubooruPoolSearchModeProvider.notifier).state =
          SzurubooruPoolSearchMode.suggestion,
    );
  }
}

class _SzurubooruPoolResultView extends ConsumerWidget {
  const _SzurubooruPoolResultView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(szurubooruPoolFilterProvider);

    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CustomScrollView(
          slivers: [
            SzurubooruPoolPagedSliverGrid(
              order: order,
              constraints: constraints,
              name: ref.watch(szurubooruPoolQueryProvider),
            ),
          ],
        ),
      ),
    );
  }
}

class _SzurubooruPoolSuggestionView extends ConsumerWidget {
  const _SzurubooruPoolSuggestionView({
    required this.textEditingController,
  });

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DebounceText(
      controller: textEditingController,
      debounceKey: 'szurubooru_pool_search',
      builder: (context, query) {
        if (query.isEmpty) {
          return const SizedBox.shrink();
        }

        return ref
            .watch(szurubooruPoolSuggestionsProvider(query))
            .maybeWhen(
              data: (pools) => pools.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      itemCount: pools.length,
                      itemBuilder: (context, index) {
                        final pool = pools[index];

                        return ListTile(
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            pool.name?.replaceAll('_', ' ') ?? '???',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _poolCategoryToColor(pool),
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
                            final poolName = pool.name;

                            if (poolName == null) return;
                            textEditingController.text = poolName.replaceAll(
                              '_',
                              ' ',
                            );
                            ref
                                    .read(szurubooruPoolQueryProvider.notifier)
                                    .state =
                                poolName;
                            ref
                                    .read(
                                      szurubooruPoolSearchModeProvider.notifier,
                                    )
                                    .state =
                                SzurubooruPoolSearchMode.result;
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

Color _poolCategoryToColor(SzurubooruPool pool) {
  final category = pool.category?.toLowerCase();

  return switch (category) {
    'series' => TagColors.dark().copyright,
    _ => TagColors.dark().general,
  };
}
