// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'danbooru_pool_page.dart';

class PoolSearchPage extends ConsumerStatefulWidget {
  const PoolSearchPage({super.key});

  @override
  ConsumerState<PoolSearchPage> createState() => _PoolSearchPageState();
}

class _PoolSearchPageState extends ConsumerState<PoolSearchPage> {
  final textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(danbooruPoolSearchModeProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _SearchBar(textEditingController: textEditingController),
      ),
      body: switch (mode) {
        PoolSearchMode.suggestion => _SuggestionView(
            textEditingController: textEditingController,
          ),
        PoolSearchMode.result => const _ResultView(),
      },
    );
  }
}

class _ResultView extends ConsumerWidget {
  const _ResultView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CustomScrollView(
          slivers: [
            PoolPagedSliverGrid(
              order: ref.watch(danbooruSelectedPoolOrderProvider),
              category: ref.watch(danbooruSelectedPoolCategoryProvider),
              constraints: constraints,
              name: ref.watch(danbooruPoolQueryProvider),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionView extends ConsumerWidget {
  const _SuggestionView({
    required this.textEditingController,
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
                            style: const TextStyle(color: Colors.grey),
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

class _SearchBar extends ConsumerWidget {
  const _SearchBar({
    required this.textEditingController,
  });

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(danbooruPoolQueryProvider);

    return BooruSearchBar(
      leading: IconButton(
        splashRadius: 16,
        onPressed: () => context.navigator.pop(),
        icon: const Icon(
          Symbols.arrow_back,
        ),
      ),
      queryEditingController: textEditingController,
      autofocus: true,
      trailing: query != null && query.isNotEmpty
          ? IconButton(
              onPressed: () {
                textEditingController.clear();
                ref.read(danbooruPoolQueryProvider.notifier).state = '';
              },
              icon: const Icon(Symbols.close),
            )
          : const SizedBox.shrink(),
      onChanged: (value) =>
          ref.read(danbooruPoolQueryProvider.notifier).state = value,
      onSubmitted: (value) {
        ref.read(danbooruPoolSearchModeProvider.notifier).state =
            PoolSearchMode.result;
      },
      hintText: 'pool.search.hint'.tr(),
      onTap: () => ref.read(danbooruPoolSearchModeProvider.notifier).state =
          PoolSearchMode.suggestion,
    );
  }
}

Color _poolCategoryToColor(DanbooruPoolCategory category) => switch (category) {
      DanbooruPoolCategory.series => TagColors.dark().copyright,
      _ => TagColors.dark().general,
    };
