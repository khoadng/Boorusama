// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/most_searched_tag_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/infra/local/repositories/metatags/user_metatag_repository.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/simple_tag_search_view.dart';
import 'package:boorusama/core/application/tags/tags.dart';
import 'package:boorusama/core/domain/tags/favorite_tag.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/ui/info_container.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/main.dart';
import 'import_favorite_tag_dialog.dart';
import 'search_history.dart';

class SearchOptions extends StatefulWidget {
  const SearchOptions({
    super.key,
    this.onOptionTap,
    this.onHistoryTap,
    this.onTagTap,
    this.onHistoryRemoved,
    required this.metatags,
  });

  final ValueChanged<String>? onOptionTap;
  final ValueChanged<String>? onHistoryTap;
  final ValueChanged<String>? onHistoryRemoved;
  final ValueChanged<String>? onTagTap;

  final List<Metatag> metatags;

  @override
  State<SearchOptions> createState() => _SearchOptionsState();
}

class _SearchOptionsState extends State<SearchOptions>
    with TickerProviderStateMixin {
  late final animationController = AnimationController(
    vsync: this,
    duration: kThemeAnimationDuration,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          if (!mounted) return;
          animationController.forward();
        },
      );
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animationController,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OptionTagsArena(
                title: 'Metatags',
                titleTrailing: (editMode) => IconButton(
                  onPressed: () {
                    launchExternalUrl(
                      Uri.parse(cheatsheetUrl),
                      mode: LaunchMode.platformDefault,
                    );
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.circleQuestion,
                    size: 18,
                  ),
                ),
                childrenBuilder: (editMode) =>
                    _buildMetatags(context, editMode),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(thickness: 1),
              BlocBuilder<FavoriteTagBloc, FavoriteTagState>(
                builder: (context, state) {
                  return _OptionTagsArena(
                    editable: state.tags.isNotEmpty,
                    title: 'Favorites',
                    childrenBuilder: (editMode) =>
                        _buildFavoriteTags(context, state.tags, editMode),
                    titleTrailing: (editMode) => editMode &&
                            state.tags.isNotEmpty
                        ? PopupMenuButton(
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                            onSelected: (value) {
                              final bloc = context.read<FavoriteTagBloc>();
                              if (value == 'import') {
                                _showImportDialog(context, bloc);
                              } else if (value == 'export') {
                                bloc.add(
                                  FavoriteTagExported(
                                    onDone: (tagString) => Clipboard.setData(
                                      ClipboardData(text: tagString),
                                    ).then((value) => showSimpleSnackBar(
                                          context: context,
                                          content:
                                              const Text('Tag string copied'),
                                        )),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'import',
                                child: Text('Import'),
                              ),
                              const PopupMenuItem(
                                value: 'export',
                                child: Text('Export'),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  );
                },
              ),
              const Divider(thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'search.trending'.tr().toUpperCase(),
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              BlocBuilder<SearchKeywordCubit, AsyncLoadState<List<Search>>>(
                builder: (context, state) {
                  return state.status != LoadStatus.success
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : Wrap(
                          spacing: 4,
                          runSpacing: -4,
                          children: state.data!
                              .take(15)
                              .map((e) => GestureDetector(
                                    onTap: () =>
                                        widget.onTagTap?.call(e.keyword),
                                    child: Chip(
                                      label: Text(
                                        e.keyword.replaceAll('_', ' '),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                },
              ),
              SearchHistorySection(
                onHistoryTap: (history) => widget.onHistoryTap?.call(history),
                onHistoryRemoved: (history) =>
                    widget.onHistoryRemoved?.call(history),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Object?> _showImportDialog(
    BuildContext context,
    FavoriteTagBloc bloc,
  ) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => ImportFavoriteTagsDialog(
        onImport: (tagString) => bloc.add(FavoriteTagImported(
          tagString: tagString,
        )),
      ),
    );
  }

  List<Widget> _buildMetatags(BuildContext context, bool editMode) {
    return [
      ...context
          .read<UserMetatagRepository>()
          .getAll()
          .map((tag) => GestureDetector(
                onTap: editMode ? null : () => widget.onOptionTap?.call(tag),
                child: Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 18,
                  ),
                  onDeleted: editMode
                      ? () async {
                          await context
                              .read<UserMetatagRepository>()
                              .delete(tag);
                          setState(() => {});
                        }
                      : null,
                ),
              )),
      if (editMode)
        IconButton(
          iconSize: 28,
          splashRadius: 20,
          onPressed: () {
            showAdaptiveBottomSheet(
              context,
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Metatags'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      onPressed: Navigator.of(context).pop,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    InfoContainer(
                      contentBuilder: (context) =>
                          const Text('search.metatags_notice').tr(),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.metatags.length,
                        itemBuilder: (context, index) {
                          final tag = widget.metatags[index];

                          return ListTile(
                            onTap: () => setState(() {
                              Navigator.of(context).pop();
                              context
                                  .read<UserMetatagRepository>()
                                  .put(tag.name);
                            }),
                            title: Text(tag.name),
                            trailing: tag.isFree
                                ? const Chip(label: Text('Free'))
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          icon: const Icon(Icons.add),
        ),
    ];
  }

  List<Widget> _buildFavoriteTags(
    BuildContext context,
    List<FavoriteTag> tags,
    bool editMode,
  ) {
    return [
      ...tags.mapIndexed((index, tag) => GestureDetector(
            onTap: editMode ? null : () => widget.onTagTap?.call(tag.name),
            child: RawChip(
              label: Text(tag.name.replaceAll('_', ' ')),
              deleteIcon: const Icon(
                Icons.close,
                size: 18,
              ),
              onDeleted: editMode
                  ? () => context
                      .read<FavoriteTagBloc>()
                      .add(FavoriteTagRemoved(index: index))
                  // ignore: no-empty-block
                  : null,
            ),
          )),
      if (tags.isEmpty) ...[
        _buildAddTagButton(),
        Padding(
          padding: const EdgeInsets.only(top: 12, right: 8),
          child: Text(
            'or',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
          onPressed: () => _showImportDialog(
            context,
            context.read<FavoriteTagBloc>(),
          ),
          child: const Text('Import'),
        ),
      ],
      if (editMode && tags.isNotEmpty) _buildAddTagButton(),
    ];
  }

  Widget _buildAddTagButton() {
    return IconButton(
      iconSize: 28,
      splashRadius: 20,
      onPressed: () {
        final bloc = context.read<FavoriteTagBloc>();
        showBarModalBottomSheet(
          context: context,
          duration: const Duration(milliseconds: 200),
          builder: (context) => SimpleTagSearchView(
            ensureValidTag: false,
            floatingActionButton: (text) => text.isEmpty
                ? const SizedBox.shrink()
                : FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      bloc.add(FavoriteTagAdded(tag: text));
                    },
                    child: const Icon(Icons.add),
                  ),
            onSelected: (tag) {
              bloc.add(FavoriteTagAdded(tag: tag.value));
            },
          ),
        );
      },
      icon: const Icon(Icons.add),
    );
  }
}

class _OptionTagsArena extends StatefulWidget {
  const _OptionTagsArena({
    required this.title,
    this.titleTrailing,
    required this.childrenBuilder,
    this.editable = true,
  });

  final String title;
  final Widget Function(bool editMode)? titleTrailing;
  final List<Widget> Function(bool editMode) childrenBuilder;
  final bool editable;

  @override
  State<_OptionTagsArena> createState() => __OptionTagsArenaState();
}

class __OptionTagsArenaState extends State<_OptionTagsArena> {
  bool editMode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: _buildHeader(),
        ),
        Wrap(
          spacing: 4,
          runSpacing: -4,
          children: widget.childrenBuilder(editMode),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                widget.title.toUpperCase(),
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (widget.editable)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: const CircleBorder(),
                    backgroundColor: editMode
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).cardColor,
                  ),
                  onPressed: () => setState(() => editMode = !editMode),
                  child: Icon(
                    editMode ? Icons.check : Icons.edit,
                    size: 16,
                  ),
                ),
            ],
          ),
          widget.titleTrailing?.call(editMode) ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
