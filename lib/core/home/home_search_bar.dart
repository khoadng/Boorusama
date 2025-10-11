// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../foundation/app_update/providers.dart';
import '../../foundation/app_update/types.dart';
import '../../foundation/display.dart';
import '../../foundation/url_launcher.dart';
import '../configs/config/types.dart';
import '../configs/ref.dart';
import '../search/histories/providers.dart';
import '../search/search/routes.dart';
import '../search/search/src/widgets/search_app_bar.dart';
import '../search/search/widgets.dart';
import '../search/selected_tags/providers.dart';
import '../settings/providers.dart';
import '../tags/metatag/providers.dart';
import '../theme.dart';
import 'home_page_controller.dart';

class HomeSearchBar extends ConsumerWidget {
  const HomeSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeController = InheritedHomePageController.maybeOf(context);

    return BooruSearchBar(
      enabled: false,
      trailing: ref
          .watch(appUpdateStatusProvider)
          .maybeWhen(
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
                    routeSettings: const RouteSettings(
                      name: 'app_update_notice',
                    ),
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
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.t.app_update.update_available,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
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
                                  context.t.app_update.whats_new,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
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
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(context.t.app_update.later),
                                ),
                                const SizedBox(width: 16),
                                FilledButton(
                                  onPressed: () {
                                    launchExternalUrlString(d.storeUrl);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(context.t.app_update.update),
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
      settingsProvider.select((value) => value.persistSearchBar),
    );

    if (context.isLargeScreen) {
      return MediaQuery.sizeOf(context).height >= 550
          ? SliverPinnedHeader(
              child: ColoredBox(
                color: colorScheme.surface,
                child: _buildDesktop(),
              ),
            )
          : SliverToBoxAdapter(
              child: _buildDesktop(),
            );
    } else {
      return SliverAppBar(
        primary: widget.primary ?? true,
        backgroundColor: colorScheme.surface,
        title: LayoutBuilder(
          builder: (context, constraints) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: kSearchAppBarWidth,
                  ),
                  child: const HomeSearchBar(),
                ),
              ),
            ],
          ),
        ),
        floating: true,
        snap: true,
        pinned: persistentSearchBar,
        automaticallyImplyLeading: false,
      );
    }
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
