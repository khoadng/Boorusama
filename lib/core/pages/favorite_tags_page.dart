// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/utils/stream/text_editing_controller_utils.dart';
import 'package:boorusama/widgets/widgets.dart';

const kFavoriteTagsSelectedLabelKey = 'favorite_tags_selected_label';

final selectedFavoriteTagQueryProvider =
    StateProvider.autoDispose<String>((ref) {
  return '';
});

class FavoriteTagsPage extends ConsumerWidget {
  const FavoriteTagsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite tags'),
      ),
      body: FavoriteTagsFilterScope(
        filterQuery: ref.watch(selectedFavoriteTagQueryProvider),
        initialValue:
            ref.watch(miscDataProvider(kFavoriteTagsSelectedLabelKey)),
        builder: (context, tags, labels, selected) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: BooruSearchBar(
                hintText: 'Filter...',
                onChanged: (value) => ref
                    .read(selectedFavoriteTagQueryProvider.notifier)
                    .state = value,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: Row(
                children: [
                  TagLabelsDropDownButton(
                    tagLabels: labels,
                    selectedLabel: selected,
                    alignment: AlignmentDirectional.centerStart,
                    onChanged: (value) {
                      ref
                          .read(
                            miscDataProvider(kFavoriteTagsSelectedLabelKey)
                                .notifier,
                          )
                          .put(value);
                    },
                  ),
                ],
              ),
            ),
            tags.isNotEmpty
                ? Expanded(
                    child: _buildTags(tags, ref),
                  )
                : const Center(
                    child: Text('No tags'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(
    List<FavoriteTag> tags,
    WidgetRef ref,
  ) {
    return ListView.builder(
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        final labels = tag.labels ?? <String>[];
        final colors = context.generateChipColors(
          context.colorScheme.primary,
          ref.watch(settingsProvider),
        );

        return ListTile(
          title: Text(tag.name),
          subtitle: labels.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final label in labels)
                        SizedBox(
                          height: 28,
                          child: RawChip(
                            onPressed: () {},
                            padding: isMobilePlatform()
                                ? const EdgeInsets.all(4)
                                : EdgeInsets.zero,
                            visualDensity: const ShrinkVisualDensity(),
                            backgroundColor: colors?.backgroundColor,
                            side: colors != null
                                ? BorderSide(
                                    color: colors.borderColor,
                                    width: 1,
                                  )
                                : null,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            label: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: context.screenWidth * 0.7,
                              ),
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  text: label,
                                  style: TextStyle(
                                    color: colors?.foregroundColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : null,
          trailing: BooruPopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  final tag = tags[index];
                  ref.read(favoriteTagsProvider.notifier).remove(tag.name);
                  break;
                case 'edit':
                  showMaterialModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (context) => EditFavoriteTagSheet(
                      initialValue: tag,
                      title: tag.name,
                      onSubmit: (tag) {
                        ref.read(favoriteTagsProvider.notifier).update(
                              tag.name,
                              tag,
                            );
                      },
                    ),
                  );
                  break;
              }
            },
            itemBuilder: const {
              'edit': Text('Edit'),
              'delete': Text('Delete'),
            },
          ),
        );
      },
    );
  }
}

class EditFavoriteTagSheet extends ConsumerStatefulWidget {
  const EditFavoriteTagSheet({
    super.key,
    required this.onSubmit,
    required this.initialValue,
    this.title,
  });

  final String? title;
  final FavoriteTag initialValue;
  final void Function(FavoriteTag tag) onSubmit;

  @override
  ConsumerState<EditFavoriteTagSheet> createState() =>
      _EditSavedSearchSheetState();
}

class _EditSavedSearchSheetState extends ConsumerState<EditFavoriteTagSheet> {
  // final queryTextController = TextEditingController();
  final labelTextController = TextEditingController();

  final queryHasText = ValueNotifier(false);
  final labelsHasText = ValueNotifier(false);

  final compositeSubscription = CompositeSubscription();

  @override
  void initState() {
    super.initState();
    // queryTextController
    //     .textAsStream()
    //     .distinct()
    //     .listen((event) => queryHasText.value = event.isNotEmpty)
    //     .addTo(compositeSubscription);

    labelTextController
        .textAsStream()
        .distinct()
        .listen((event) => labelsHasText.value = event.isNotEmpty)
        .addTo(compositeSubscription);

    // queryTextController.text = widget.initialValue.name;
    labelTextController.text = widget.initialValue.labels?.join(' ') ?? '';
  }

  @override
  void dispose() {
    // queryTextController.dispose();
    labelTextController.dispose();
    compositeSubscription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.secondaryContainer,
      child: Container(
        margin: EdgeInsets.only(
          left: 30,
          right: 30,
          top: 1,
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                widget.title ?? 'Edit',
                style: context.textTheme.titleLarge,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            // BooruTextField(
            //   autofocus: true,
            //   controller: queryTextController,
            //   maxLines: null,
            //   decoration: InputDecoration(
            //     hintText: 'saved_search.saved_search_query'.tr(),
            //     suffixIcon: Material(
            //       color: Colors.transparent,
            //       child: InkWell(
            //         customBorder: const CircleBorder(),
            //         onTap: () {
            //           goToQuickSearchPage(
            //             context,
            //             ref: ref,
            //             onSelected: (tag) {
            //               final baseOffset =
            //                   max(0, queryTextController.selection.baseOffset);
            //               queryTextController
            //                 ..text = queryTextController.text.addCharAtPosition(
            //                   tag.value,
            //                   baseOffset,
            //                 )
            //                 ..selection = TextSelection.fromPosition(
            //                   TextPosition(
            //                     offset: baseOffset + tag.value.length,
            //                   ),
            //                 );
            //             },
            //             onSubmitted: (context, text) {
            //               context.navigator.pop();

            //               queryTextController.text =
            //                   '${queryTextController.text} $text';
            //             },
            //           );
            //         },
            //         child: const Icon(Symbols.add),
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(
              height: 16,
            ),
            BooruTextField(
              controller: labelTextController,
              maxLines: null,
              decoration: const InputDecoration(
                label: Text('Labels'),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              child: Text(
                "*A list of label to help categorize this tag. Space delimited.",
                style: context.textTheme.titleSmall!.copyWith(
                  color: context.theme.hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              child: ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      foregroundColor: context.iconTheme.color,
                      backgroundColor: context.colorScheme.surfaceVariant,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onPressed: () {
                      context.navigator.pop();
                    },
                    child: const Text('generic.action.cancel').tr(),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      foregroundColor: context.iconTheme.color,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onPressed: () {
                      widget.onSubmit(
                        widget.initialValue.copyWith(
                          labels: () => labelTextController.text.isEmpty
                              ? null
                              : labelTextController.text.split(' '),
                        ),
                      );
                      context.navigator.pop();
                    },
                    child: const Text('generic.action.ok').tr(),
                  ),
                  // ValueListenableBuilder<bool>(
                  //   valueListenable: queryHasText,
                  //   builder: (context, enable, _) => FilledButton(
                  //     style: FilledButton.styleFrom(
                  //       foregroundColor: context.iconTheme.color,
                  //       shape: const RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.all(Radius.circular(16)),
                  //       ),
                  //     ),
                  //     onPressed: enable
                  //         ? () {
                  //             widget.onSubmit(
                  //               queryTextController.text,
                  //               labelTextController.text,
                  //             );
                  //             context.navigator.pop();
                  //           }
                  //         : null,
                  //     child: const Text('generic.action.ok').tr(),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
