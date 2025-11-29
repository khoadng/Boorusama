// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../../foundation/app_update/widgets.dart';
import '../../../../foundation/display.dart';
import '../../../configs/config/providers.dart';
import '../../../configs/config/types.dart';
import '../../../search/histories/providers.dart';
import '../../../search/search/routes.dart';
import '../../../search/search/widgets.dart';
import '../../../search/selected_tags/providers.dart';
import '../../../settings/providers.dart';
import '../../../tags/metatag/providers.dart';
import '../controllers/home_page_controller.dart';

class HomeSearchBar extends ConsumerWidget {
  const HomeSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeController = InheritedHomePageController.maybeOf(context);

    return BooruSearchBar(
      enabled: false,
      trailing: const AppUpdateButton(),
      leading: IconButton(
        splashRadius: 16,
        icon: const Icon(Symbols.menu),
        onPressed: () {
          homeController?.openMenu();
        },
      ),
      onTap: () => goToSearchPage(ref, fromSearchBar: true),
    );
  }
}

class SliverHomeSearchBar extends ConsumerWidget {
  const SliverHomeSearchBar({
    required this.onSearch,
    super.key,
    this.selectedTagString,
    this.selectedTagController,
    this.primary,
  });

  final ValueNotifier<String>? selectedTagString;
  final void Function() onSearch;
  final SelectedTagController? selectedTagController;
  final bool? primary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return SliverHomeSearchBarInternal(
      selectedTagString: selectedTagString,
      onSearch: onSearch,
      selectedTagController: selectedTagController,
      config: config,
      primary: primary,
    );
  }
}

class SliverHomeSearchBarInternal extends ConsumerStatefulWidget {
  const SliverHomeSearchBarInternal({
    required this.onSearch,
    required this.config,
    super.key,
    this.selectedTagString,
    this.selectedTagController,
    this.primary,
  });

  final ValueNotifier<String>? selectedTagString;
  final void Function() onSearch;
  final SelectedTagController? selectedTagController;
  final BooruConfigAuth config;
  final bool? primary;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SliverHomeSearchBarState();
}

class _SliverHomeSearchBarState
    extends ConsumerState<SliverHomeSearchBarInternal> {
  late final SelectedTagController selectedTagController;

  late final selectedTagString = widget.selectedTagString ?? ValueNotifier('');

  @override
  void initState() {
    super.initState();

    selectedTagController =
        widget.selectedTagController ??
        SelectedTagController(
          metatagExtractor: ref.read(metatagExtractorProvider(widget.config)),
        );
  }

  @override
  void dispose() {
    if (widget.selectedTagController == null) {
      selectedTagController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final persistentSearchBar = ref.watch(
      settingsProvider.select(
        (value) => value.searchBarScrollBehavior.persistSearchBar,
      ),
    );

    // Desktop variant
    if (context.isLargeScreen) {
      final child = ColoredBox(
        color: colorScheme.surface,
        child: DesktopSearchbar(
          onSearch: _onSearch,
          selectedTagController: selectedTagController,
        ),
      );

      return MediaQuery.heightOf(context) >= 550
          ? SliverPinnedHeader(child: child)
          : SliverToBoxAdapter(child: child);
    }

    // Mobile variant
    return SliverAppBar(
      primary: widget.primary ?? true,
      backgroundColor: colorScheme.surface,
      title: const HomeSearchBar(),
      floating: true,
      snap: true,
      pinned: persistentSearchBar,
      automaticallyImplyLeading: false,
    );
  }

  void _onSearch() {
    ref
        .read(searchHistoryProvider.notifier)
        .addHistoryFromController(selectedTagController);
    selectedTagString.value = selectedTagController.rawTagsString;
    widget.onSearch();
  }
}
