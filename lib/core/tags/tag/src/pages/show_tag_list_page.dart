// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../../../foundation/clipboard.dart';
import '../../../../../foundation/platform.dart';
import '../../../../../foundation/toast.dart';
import '../../../../blacklists/providers.dart';
import '../../../../configs/config.dart';
import '../../../../posts/post/post.dart';
import '../../../../search/search/routes.dart';
import '../../../../search/search/widgets.dart';
import '../../../../settings/providers.dart';
import '../../../../widgets/animated_footer.dart';
import '../../../../widgets/selection_app_bar_builder.dart';
import '../../../favorites/providers.dart';
import '../../widgets.dart';
import '../data/providers.dart';
import '../types/tag.dart';
import '../types/tag_display.dart';
import '../widgets/filterable_scope.dart';

final selectedViewTagQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

final _tagsProvider = FutureProvider.autoDispose
    .family<List<Tag>, (BooruConfigAuth, Post)>((ref, params) async {
      final (config, post) = params;
      final tagExtractor = ref.watch(tagExtractorProvider(config));

      if (tagExtractor == null) return [];

      return tagExtractor.extractTags(post);
    });

class ShowTagListPage extends ConsumerWidget {
  const ShowTagListPage({
    required this.post,
    required this.auth,
    required this.initiallyMultiSelectEnabled,
    super.key,
    this.onAddToBlacklist,
    this.onOpenWiki,
    this.contextMenuBuilder,
  });

  final Post post;
  final void Function(Tag tag)? onAddToBlacklist;
  final void Function(Tag tag)? onOpenWiki;
  final BooruConfigAuth auth;
  final bool initiallyMultiSelectEnabled;
  final Widget Function(Widget child, String tag)? contextMenuBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (auth, post);

    final globalNotifier = ref.watch(globalBlacklistedTagsProvider.notifier);
    final favoriteNotifier = ref.watch(favoriteTagsProvider.notifier);

    return ref
        .watch(_tagsProvider(params))
        .when(
          data: (tags) => ShowTagListPageInternal(
            tags: tags,
            auth: auth,
            initiallyMultiSelectEnabled: initiallyMultiSelectEnabled,
            onAddToBlacklist: onAddToBlacklist,
            onAddToGlobalBlacklist: (tag) {
              globalNotifier.addTagWithToast(
                context,
                tag.rawName,
              );
            },
            onAddToFavoriteTags: (tag) async {
              await favoriteNotifier.add(tag.rawName);

              if (!context.mounted) return;

              showSuccessToast(
                context,
                'Added'.hc,
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                ),
              );
            },
            onOpenWiki: onOpenWiki,
            contextMenuBuilder: contextMenuBuilder,
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(
              title: Text('Error'.hc),
            ),
            body: Center(
              child: Text('Error loading tags: $error'),
            ),
          ),
          loading: () => Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
  }
}

class ShowTagListPageInternal extends ConsumerStatefulWidget {
  const ShowTagListPageInternal({
    required this.tags,
    required this.auth,
    required this.initiallyMultiSelectEnabled,
    super.key,
    this.onAddToBlacklist,
    this.onAddToGlobalBlacklist,
    this.onAddToFavoriteTags,
    this.onOpenWiki,
    this.contextMenuBuilder,
  });

  final List<Tag> tags;
  final void Function(Tag tag)? onAddToBlacklist;
  final void Function(Tag tag)? onAddToGlobalBlacklist;
  final void Function(Tag tag)? onAddToFavoriteTags;
  final void Function(Tag tag)? onOpenWiki;
  final BooruConfigAuth auth;
  final bool initiallyMultiSelectEnabled;
  final Widget Function(Widget child, String tag)? contextMenuBuilder;

  @override
  ConsumerState<ShowTagListPageInternal> createState() =>
      _ShowTagListPageState();
}

class _ShowTagListPageState extends ConsumerState<ShowTagListPageInternal> {
  late final SelectionModeController _selectionModeController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _selectionModeController = SelectionModeController(
      initialEnabled: widget.initiallyMultiSelectEnabled,
    );
  }

  @override
  void dispose() {
    _selectionModeController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: SelectionMode(
        scrollController: _scrollController,
        controller: _selectionModeController,
        options: ref.watch(selectionOptionsProvider),
        child: Scaffold(
          appBar: SelectionAppBarBuilder(
            builder: (context, controller, isSelectionMode) => !isSelectionMode
                ? AppBar(
                    title: Text('Tags'.hc),
                    actions: [
                      BooruPopupMenuButton(
                        onSelected: (value) {
                          switch (value) {
                            case 'select':
                              controller.enable();
                            default:
                          }
                        },
                        itemBuilder: const {
                          'select': Text('Select'),
                        },
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Symbols.close),
                      ),
                    ],
                  )
                : AppBar(
                    title: ListenableBuilder(
                      listenable: controller,
                      builder: (context, _) {
                        final selectedItems = controller.selection;

                        return selectedItems.isEmpty
                            ? Text('Select tags'.hc)
                            : Text(
                                '${selectedItems.length} Tags selected'.hc,
                              );
                      },
                    ),
                    actions: [
                      IconButton(
                        onPressed: () => controller.selectAll(
                          List.generate(
                            widget.tags.length,
                            (index) => index,
                          ),
                        ),
                        icon: const Icon(Symbols.select_all),
                      ),
                      IconButton(
                        onPressed: () => controller.deselectAll(),
                        icon: const Icon(Symbols.clear_all),
                      ),
                      IconButton(
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () => controller.disable(),
                        icon: const Icon(Symbols.check),
                      ),
                    ],
                  ),
          ),
          body: Stack(
            children: [
              FilterableScope(
                originalItems: widget.tags,
                query: ref.watch(selectedViewTagQueryProvider),
                filter: (item, query) => item.rawName.contains(query),
                builder: (context, items) => Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 4),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          final tag = items[index];
                          final child = _SelectableTagItem(
                            index: index,
                            tag: tag,
                            auth: widget.auth,
                            onAddToBlacklist: widget.onAddToBlacklist,
                            onAddToGlobalBlacklist:
                                widget.onAddToGlobalBlacklist,
                            onAddToFavoriteTags: widget.onAddToFavoriteTags,
                            onOpenWiki: widget.onOpenWiki,
                          );

                          return widget.contextMenuBuilder != null
                              ? widget.contextMenuBuilder!(
                                  child,
                                  tag.rawName,
                                )
                              : GeneralTagContextMenu(
                                  tag: tag.rawName,
                                  child: child,
                                );
                        },
                        itemCount: items.length,
                      ),
                    ),
                  ],
                ),
              ),
              ListenableBuilder(
                listenable: _selectionModeController,
                builder: (context, _) => Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildContent(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final tags = _selectionModeController.selectedFrom(widget.tags).toList();

    return SelectionModeAnimatedFooter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (tags.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    ...tags.map(
                      (tag) => TextSpan(
                        text: '${tag.displayName}  ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: ref.watch(
                            tagColorProvider(
                              (widget.auth, tag.category.name),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          MultiSelectionActionBar(
            height: 68,
            children: [
              MultiSelectButton(
                onPressed: tags.isNotEmpty
                    ? () => _copySelectedTags(tags)
                    : null,
                icon: const Icon(Symbols.content_copy),
                name: 'Copy Tags',
                mainAxisAlignment: MainAxisAlignment.start,
              ),
              if (widget.onAddToBlacklist != null)
                MultiSelectButton(
                  onPressed: tags.isNotEmpty
                      ? () => _addSelectedToBlacklist(tags)
                      : null,
                  icon: const Icon(Symbols.block),
                  name: 'Add to Blacklist',
                  maxLines: 2,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              MultiSelectButton(
                onPressed: tags.isNotEmpty
                    ? () => _addSelectedToGlobalBlacklist(tags)
                    : null,
                icon: const Icon(Symbols.block),
                name: 'Add to Global Blacklist',
                maxLines: 2,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
              MultiSelectButton(
                onPressed: tags.isNotEmpty
                    ? () => _addSelectedToFavorites(tags)
                    : null,
                icon: const Icon(Symbols.favorite),
                name: 'Add to Favorites',
                maxLines: 2,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      child: BooruSearchBar(
        dense: true,
        hintText: 'Filter...'.hc,
        onChanged: (value) =>
            ref.read(selectedViewTagQueryProvider.notifier).state = value,
      ),
    );
  }

  void _copySelectedTags(List<Tag> tags) {
    final selectedTags = tags.join(' ');

    AppClipboard.copyWithDefaultToast(
      context,
      selectedTags,
    );

    _selectionModeController.disable();
  }

  void _addSelectedToBlacklist(List<Tag> tags) {
    for (final tag in tags) {
      widget.onAddToBlacklist?.call(tag);
    }

    _selectionModeController.disable();
  }

  void _addSelectedToGlobalBlacklist(List<Tag> tags) {
    for (final tag in tags) {
      widget.onAddToGlobalBlacklist?.call(tag);
    }

    _selectionModeController.disable();
  }

  void _addSelectedToFavorites(List<Tag> tags) {
    for (final tag in tags) {
      widget.onAddToFavoriteTags?.call(tag);
    }
    _selectionModeController.disable();
  }
}

class _SelectableTagItem extends StatelessWidget {
  const _SelectableTagItem({
    required this.index,
    required this.tag,
    required this.auth,
    this.onAddToBlacklist,
    this.onAddToGlobalBlacklist,
    this.onAddToFavoriteTags,
    this.onOpenWiki,
  });

  final int index;
  final Tag tag;
  final BooruConfigAuth auth;
  final void Function(Tag tag)? onAddToBlacklist;
  final void Function(Tag tag)? onAddToGlobalBlacklist;
  final void Function(Tag tag)? onAddToFavoriteTags;
  final void Function(Tag tag)? onOpenWiki;

  @override
  Widget build(BuildContext context) {
    return SelectableBuilder(
      index: index,
      builder: (context, isSelected) {
        final controller = SelectionMode.of(context);
        final multiSelect = controller.isActive;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: multiSelect ? 36 : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: multiSelect ? 1.0 : 0.0,
                  child: multiSelect
                      ? Checkbox(
                          visualDensity: VisualDensity.compact,
                          value: isSelected,
                          onChanged: (value) {
                            if (value == null) return;
                            controller.toggleItem(index);
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              Expanded(
                child: _TagTile(
                  tag: tag,
                  auth: auth,
                  index: index,
                  multiSelect: multiSelect,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TagTile extends StatefulWidget {
  const _TagTile({
    required this.tag,
    required this.auth,
    required this.index,
    required this.multiSelect,
  });

  final Tag tag;
  final BooruConfigAuth auth;
  final int index;
  final bool multiSelect;

  @override
  State<_TagTile> createState() => _TagTileState();
}

class _TagTileState extends State<_TagTile> {
  final _hover = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final controller = SelectionMode.of(context);

    return MouseRegion(
      onEnter: (_) => _hover.value = true,
      onExit: (_) => _hover.value = false,
      child: Consumer(
        builder: (_, ref, _) => ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          visualDensity: VisualDensity.compact,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          title: Text(
            widget.tag.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ref.watch(
                tagColorProvider(
                  (widget.auth, widget.tag.category.name),
                ),
              ),
              fontSize: 14,
            ),
          ),
          onTap: widget.multiSelect
              ? () => controller.toggleItem(widget.index)
              : () => goToSearchPage(
                  ref,
                  tag: widget.tag.rawName,
                ),
          trailing: isDesktopPlatform()
              ? ValueListenableBuilder(
                  valueListenable: _hover,
                  builder: (_, isHovered, _) => isHovered
                      ? _buildTrailing(context)
                      : const SizedBox.shrink(),
                )
              : _buildTrailing(context),
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Icon(
      Symbols.chevron_right,
      color: Theme.of(context).colorScheme.outline,
    );
  }
}
