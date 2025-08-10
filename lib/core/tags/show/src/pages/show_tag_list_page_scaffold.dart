// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../posts/post/post.dart';
import '../../../../search/search/widgets.dart';
import '../../../../settings/providers.dart';
import '../../../../widgets/selection_app_bar_builder.dart';
import '../../../../widgets/widgets.dart';
import '../providers.dart';

class ShowTagListPageScaffold extends ConsumerStatefulWidget {
  const ShowTagListPageScaffold({
    required this.post,
    required this.auth,
    required this.initiallyMultiSelectEnabled,
    required this.scrollController,
    required this.list,
    required this.actionBar,
    super.key,
  });

  final Post post;
  final ScrollController scrollController;
  final BooruConfigAuth auth;
  final bool initiallyMultiSelectEnabled;
  final Widget list;
  final Widget actionBar;

  @override
  ConsumerState<ShowTagListPageScaffold> createState() =>
      _ShowTagListPageScaffoldState();
}

class _ShowTagListPageScaffoldState
    extends ConsumerState<ShowTagListPageScaffold> {
  late final SelectionModeController _selectionModeController;

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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = (widget.auth, widget.post);

    return CustomContextMenuOverlay(
      child: SelectionMode(
        scrollController: widget.scrollController,
        controller: _selectionModeController,
        options: ref.watch(selectionOptionsProvider),
        child: Scaffold(
          appBar: SelectionAppBarBuilder(
            builder: (context, controller, isSelectionMode) => !isSelectionMode
                ? AppBar(
                    title: Text('Tags'.hc),
                    centerTitle: false,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: BooruPopupMenuButton(
                          onSelected: (value) {
                            switch (value) {
                              case 'select':
                                controller.enable();
                              default:
                            }
                          },
                          itemBuilder: {
                            'select': Text(context.t.generic.action.select),
                          },
                        ),
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
                      ref
                          .watch(showTagsProvider(params))
                          .maybeWhen(
                            data: (tags) => IconButton(
                              onPressed: () => controller.selectAll(
                                List.generate(
                                  tags.length,
                                  (index) => index,
                                ),
                              ),
                              icon: const Icon(Symbols.select_all),
                            ),
                            orElse: () => const SizedBox.shrink(),
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
              Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 4),
                  Expanded(
                    child: SelectionCanvas(
                      child: widget.list,
                    ),
                  ),
                ],
              ),
              ListenableBuilder(
                listenable: _selectionModeController,
                builder: (context, _) => Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: widget.actionBar,
                ),
              ),
            ],
          ),
        ),
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
}
