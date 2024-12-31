// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../../theme.dart';
import '../../../../utils/stream/text_editing_controller_utils.dart';
import '../favorite_tag.dart';

class EditFavoriteTagSheet extends ConsumerStatefulWidget {
  const EditFavoriteTagSheet({
    required this.onSubmit,
    required this.initialValue,
    super.key,
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
  final labelTextController = TextEditingController();

  final queryHasText = ValueNotifier(false);
  final labelsHasText = ValueNotifier(false);

  final compositeSubscription = CompositeSubscription();

  @override
  void initState() {
    super.initState();
    labelTextController
        .textAsStream()
        .distinct()
        .listen((event) => labelsHasText.value = event.isNotEmpty)
        .addTo(compositeSubscription);

    labelTextController.text = widget.initialValue.labels?.join(' ') ?? '';
  }

  @override
  void dispose() {
    labelTextController.dispose();
    compositeSubscription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Container(
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                widget.title ?? 'Edit',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
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
                '*A list of label to help categorize this tag. Space delimited.',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.hintColor,
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
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('generic.action.cancel').tr(),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                      Navigator.of(context).pop();
                    },
                    child: const Text('generic.action.ok').tr(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
