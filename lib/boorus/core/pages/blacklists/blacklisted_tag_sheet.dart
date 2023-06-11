// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/utils/stream/text_editing_controller_utils.dart';

class BlacklistedTagSheet extends StatefulWidget {
  const BlacklistedTagSheet({
    super.key,
    required this.onSubmit,
    this.title,
  });

  final String? title;
  final void Function(String name) onSubmit;

  @override
  State<BlacklistedTagSheet> createState() => _BlacklistedTagSheetState();
}

class _BlacklistedTagSheetState extends State<BlacklistedTagSheet> {
  final queryTextController = TextEditingController();

  final queryHasText = ValueNotifier(false);

  final compositeSubscription = CompositeSubscription();

  @override
  void initState() {
    super.initState();
    queryTextController
        .textAsStream()
        .distinct()
        .listen((event) => queryHasText.value = event.isNotEmpty)
        .addTo(compositeSubscription);
  }

  @override
  void dispose() {
    queryTextController.dispose();
    compositeSubscription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.only(
          left: 30,
          right: 30,
          top: 1,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                widget.title ?? 'Add a tag',
                style: context.textTheme.titleLarge,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              autofocus: true,
              controller: queryTextController,
              maxLines: null,
              decoration: _getDecoration(
                context: context,
                hint: '',
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              child: ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: context.theme.iconTheme.color,
                      backgroundColor: context.theme.cardColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onPressed: () {
                      context.navigator.pop();
                    },
                    child: const Text('generic.action.cancel').tr(),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: queryHasText,
                    builder: (context, enable, _) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: context.theme.iconTheme.color,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                      onPressed: enable
                          ? () {
                              widget.onSubmit(
                                queryTextController.text,
                              );
                              context.navigator.pop();
                            }
                          : null,
                      child: const Text('generic.action.ok').tr(),
                    ),
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

InputDecoration _getDecoration({
  required BuildContext context,
  required String hint,
  Widget? suffixIcon,
}) =>
    InputDecoration(
      suffixIcon: suffixIcon,
      hintText: hint,
      filled: true,
      fillColor: context.theme.cardColor,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: context.theme.colorScheme.secondary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: context.theme.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide:
            BorderSide(color: context.theme.colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.all(12),
    );
