// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/saved_searches/saved_searches.dart';
import 'package:boorusama/common/stream/text_editing_controller_utils.dart';

class EditSavedSearchSheet extends StatefulWidget {
  const EditSavedSearchSheet({
    super.key,
    required this.onSubmit,
    this.initialValue,
    this.title,
  });

  final String? title;
  final SavedSearch? initialValue;
  final void Function(String name, String key) onSubmit;

  @override
  State<EditSavedSearchSheet> createState() => _EditSavedSearchSheetState();
}

class _EditSavedSearchSheetState extends State<EditSavedSearchSheet> {
  final accountTextController = TextEditingController();
  final keyTextController = TextEditingController();

  final accountNameHasText = ValueNotifier(false);
  final apiKeyHasText = ValueNotifier(false);

  final compositeSubscription = CompositeSubscription();

  @override
  void initState() {
    super.initState();
    accountTextController
        .textAsStream()
        .distinct()
        .listen((event) => accountNameHasText.value = event.isNotEmpty)
        .addTo(compositeSubscription);

    keyTextController
        .textAsStream()
        .distinct()
        .listen((event) => apiKeyHasText.value = event.isNotEmpty)
        .addTo(compositeSubscription);

    if (widget.initialValue != null) {
      accountTextController.text = widget.initialValue!.query;
      keyTextController.text = widget.initialValue!.labels.join(' ');
    }
  }

  @override
  void dispose() {
    accountTextController.dispose();
    keyTextController.dispose();
    compositeSubscription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              widget.title ?? 'Add a saved search',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          TextField(
            controller: accountTextController,
            maxLines: null,
            decoration: _getDecoration(
              context: context,
              hint: 'Query',
              suffixIcon: ValueListenableBuilder<bool>(
                valueListenable: accountNameHasText,
                builder: (context, hasText, _) => hasText
                    ? _ClearTextButton(
                        onTap: () => accountTextController.clear(),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          TextField(
            controller: keyTextController,
            maxLines: null,
            decoration: _getDecoration(
              context: context,
              hint: 'Labels*',
              suffixIcon: ValueListenableBuilder<bool>(
                valueListenable: apiKeyHasText,
                builder: (context, hasText, _) => hasText
                    ? _ClearTextButton(
                        onTap: () => keyTextController.clear(),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            child: Text(
              '*A list of tags to help categorize this search. Space delimited.',
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).hintColor,
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).iconTheme.color,
                    backgroundColor: Theme.of(context).cardColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: accountNameHasText,
                  builder: (context, enable, _) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).iconTheme.color,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onPressed: enable
                        ? () {
                            widget.onSubmit(
                              accountTextController.text,
                              keyTextController.text,
                            );
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: const Text('OK'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClearTextButton extends StatelessWidget {
  const _ClearTextButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Icon(Icons.close),
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
      fillColor: Theme.of(context).cardColor,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Theme.of(context).errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Theme.of(context).errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.all(12),
    );
