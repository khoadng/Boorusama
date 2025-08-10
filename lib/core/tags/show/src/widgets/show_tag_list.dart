// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../../foundation/platform.dart';
import '../../../../configs/config/types.dart';
import '../../../../search/search/routes.dart';
import '../../../tag/providers.dart';
import '../../../tag/tag.dart';
import '../../../tag/widgets.dart';
import '../providers.dart';
import 'filterable_scope.dart';

class ShowTagList extends ConsumerWidget {
  const ShowTagList({
    required this.tags,
    required this.scrollController,
    required this.auth,
    this.onAddToBlacklist,
    this.onAddToGlobalBlacklist,
    this.onAddToFavoriteTags,
    this.onOpenWiki,
    this.contextMenuBuilder,

    super.key,
  });

  final ScrollController scrollController;
  final List<Tag> tags;
  final BooruConfigAuth auth;
  final void Function(Tag tag)? onAddToBlacklist;
  final void Function(Tag tag)? onAddToGlobalBlacklist;
  final void Function(Tag tag)? onAddToFavoriteTags;
  final void Function(Tag tag)? onOpenWiki;
  final Widget Function(Widget child, String tag)? contextMenuBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilterableScope(
      originalItems: tags,
      query: ref.watch(
        selectedViewTagQueryProvider,
      ),
      filter: (item, query) => item.rawName.contains(query),
      builder: (context, items) => ListView.builder(
        controller: scrollController,
        itemBuilder: (context, index) {
          final tag = items[index];
          final child = _SelectableTagItem(
            index: index,
            tag: tag,
            auth: auth,
            onAddToBlacklist: onAddToBlacklist,
            onAddToGlobalBlacklist: onAddToGlobalBlacklist,
            onAddToFavoriteTags: onAddToFavoriteTags,
            onOpenWiki: onOpenWiki,
          );

          return contextMenuBuilder != null
              ? contextMenuBuilder!(
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
    );
  }
}

class ShowTagListPlaceholder extends StatelessWidget {
  const ShowTagListPlaceholder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        visualDensity: VisualDensity.compact,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: const Text(
              '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.transparent,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
      itemCount: 30,
    );
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
