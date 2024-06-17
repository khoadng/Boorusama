// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/utils/stream/text_editing_controller_utils.dart';

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
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.theme.hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 28),
              child: OverflowBar(
                alignment: MainAxisAlignment.spaceAround,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      foregroundColor: context.iconTheme.color,
                      backgroundColor: context.colorScheme.surfaceContainerHighest,
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
