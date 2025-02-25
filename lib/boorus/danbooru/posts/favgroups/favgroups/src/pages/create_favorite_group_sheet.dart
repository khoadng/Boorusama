// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../../core/configs/ref.dart';
import '../../../../../../../core/foundation/toast.dart';
import '../../../../../../../core/widgets/widgets.dart';
import '../providers/favorite_groups_notifier.dart';
import '../types/danbooru_favorite_group.dart';
import '../wigdets/privacy_toggle.dart';

class EditFavoriteGroupSheet extends ConsumerStatefulWidget {
  const EditFavoriteGroupSheet({
    required this.title,
    super.key,
    this.initialData,
    this.enableManualDataInput = true,
  });

  final String title;
  final DanbooruFavoriteGroup? initialData;
  final bool enableManualDataInput;

  @override
  ConsumerState<EditFavoriteGroupSheet> createState() =>
      _EditFavoriteGroupDialogState();
}

class _EditFavoriteGroupDialogState
    extends ConsumerState<EditFavoriteGroupSheet> {
  final textController = TextEditingController();
  final nameController = TextEditingController();
  bool isPrivate = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      textController.text = widget.initialData!.postIds.join(' ');
      nameController.text = widget.initialData!.name.replaceAll('_', ' ');
      isPrivate = !widget.initialData!.isPublic;
    }
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigSearch;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'favorite_groups.group_name'.tr().toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          BooruTextField(
            autofocus: true,
            controller: nameController,
            maxLines: 1,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'favorite_groups.group_name_hint'.tr(),
            ),
          ),
          if (widget.enableManualDataInput)
            const SizedBox(
              height: 8,
            ),
          if (widget.enableManualDataInput)
            Text(
              'favorite_groups.all_posts'.tr().toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          if (widget.enableManualDataInput)
            const SizedBox(
              height: 12,
            ),
          if (widget.enableManualDataInput)
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: BooruTextField(
                controller: textController,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintMaxLines: 4,
                  hintText:
                      '${'favorite_groups.initial_posts_hint'.tr()}\n\n\n\n\n',
                ),
              ),
            ),
          PrivacyToggle(
            isPrivate: isPrivate,
            onChanged: (value) => setState(() => isPrivate = value),
          ),
          const SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 4,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: const Text('favorite_groups.create_group_cancel').tr(),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: nameController,
                  builder: (context, value, child) => FilledButton(
                    onPressed: nameController.text.isNotEmpty
                        ? () {
                            Navigator.of(context).pop();
                            if (widget.initialData == null) {
                              ref
                                  .read(
                                    danbooruFavoriteGroupsProvider(config)
                                        .notifier,
                                  )
                                  .create(
                                    initialIds: textController.text,
                                    name: value.text,
                                    isPrivate: isPrivate,
                                    onFailure: (message, translatable) =>
                                        showErrorToast(
                                      context,
                                      translatable ? message.tr() : message,
                                    ),
                                  );
                            } else {
                              ref
                                  .read(
                                    danbooruFavoriteGroupsProvider(config)
                                        .notifier,
                                  )
                                  .edit(
                                    group: widget.initialData!,
                                    name: value.text,
                                    isPrivate: isPrivate,
                                    initialIds: textController.text,
                                    onFailure: (message, _) {
                                      showErrorToast(context, message);
                                    },
                                  );
                            }
                          }
                        : null,
                    child:
                        const Text('favorite_groups.create_group_confirm').tr(),
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
