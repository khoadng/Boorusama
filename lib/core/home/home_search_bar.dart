// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../boorus/providers.dart';
import '../app_update/providers.dart';
import '../app_update/types.dart';
import '../boorus/booru_builder.dart';
import '../foundation/display.dart';
import '../foundation/url_launcher.dart';
import '../router.dart';
import '../search/history_providers.dart';
import '../search/search_bar.dart';
import '../search/selected_tags.dart';
import '../tags/configs/providers.dart';
import '../theme.dart';
import 'home_page_controller.dart';

class HomeSearchBar extends ConsumerWidget {
  const HomeSearchBar({
    super.key,
    this.onMenuTap,
    this.onTap,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BooruSearchBar(
      enabled: false,
      trailing: ref.watch(appUpdateStatusProvider).maybeWhen(
            data: (status) => switch (status) {
              final UpdateAvailable d => IconButton(
                  splashRadius: 12,
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.arrowUp,
                      size: 14,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'app_update.update_available',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ).tr(),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _VersionChangeVisualizedText(status: d),
                                ],
                              ),
                              const Divider(thickness: 1.5),
                              Row(
                                children: [
                                  Text(
                                    'app_update.whats_new',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ).tr(),
                                ],
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 4,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: MarkdownBody(
                                            data: d.releaseNotes,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('app_update.later').tr(),
                                  ),
                                  const SizedBox(width: 16),
                                  FilledButton(
                                    onPressed: () {
                                      launchExternalUrlString(d.storeUrl);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('app_update.update').tr(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              _ => const SizedBox.shrink(),
            },
            orElse: () => const SizedBox.shrink(),
          ),
      leading: onMenuTap != null
          ? IconButton(
              splashRadius: 16,
              icon: const Icon(Symbols.menu),
              onPressed: onMenuTap,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _VersionChangeVisualizedText extends StatelessWidget {
  const _VersionChangeVisualizedText({
    required this.status,
  });

  final UpdateAvailable status;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: status.currentVersion,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.hintColor,
                ),
          ),
          const TextSpan(text: '  ➞  '),
          TextSpan(
            text: status.storeVersion,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
      ),
    );
  }
}

class SliverHomeSearchBar extends ConsumerWidget {
  const SliverHomeSearchBar({
    super.key,
    required this.controller,
    this.selectedTagString,
    required this.onSearch,
    this.selectedTagController,
  });

  final HomePageController controller;
  final ValueNotifier<String>? selectedTagString;
  final void Function() onSearch;
  final SelectedTagController? selectedTagController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(currentBooruBuilderProvider);

    return SliverHomeSearchBarInternal(
      controller: controller,
      selectedTagString: selectedTagString,
      onSearch: onSearch,
      selectedTagController: selectedTagController,
      booruBuilder: booruBuilder,
    );
  }
}

class SliverHomeSearchBarInternal extends ConsumerStatefulWidget {
  const SliverHomeSearchBarInternal({
    super.key,
    required this.controller,
    this.selectedTagString,
    required this.onSearch,
    this.selectedTagController,
    required this.booruBuilder,
  });

  final HomePageController controller;
  final ValueNotifier<String>? selectedTagString;
  final void Function() onSearch;
  final SelectedTagController? selectedTagController;
  final BooruBuilder? booruBuilder;

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
    final tagInfo = ref.read(tagInfoProvider);

    selectedTagController = widget.selectedTagController ??
        SelectedTagController.fromBooruBuilder(
          builder: widget.booruBuilder,
          tagInfo: tagInfo,
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
    if (context.isLargeScreen) {
      return MediaQuery.sizeOf(context).height >= 550
          ? _buildPinned(context)
          : SliverToBoxAdapter(
              child: _buildDesktop(),
            );
    } else {
      final homeSearchBar = HomeSearchBar(
        onMenuTap: widget.controller.openMenu,
        onTap: () => goToSearchPage(context),
      );
      return SliverAppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        toolbarHeight: kToolbarHeight * 1.2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: LimitedBox(
                maxWidth: 500,
                child: homeSearchBar,
              ),
            ),
          ],
        ),
        floating: true,
        snap: true,
        automaticallyImplyLeading: false,
      );
    }
  }

  Widget _buildPinned(BuildContext context) {
    return SliverPinnedHeader(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: _buildDesktop(),
      ),
    );
  }

  Widget _buildDesktop() {
    return DesktopSearchbar(
      onSearch: () => _onSearch(),
      selectedTagController: selectedTagController,
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
