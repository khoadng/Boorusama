// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../foundation/toast.dart';
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
  var isPrivate = false;

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
              context.t.favorite_groups.group_name.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          BooruTextField(
            autofocus: true,
            controller: nameController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: context.t.favorite_groups.group_name_hint,
            ),
          ),
          if (widget.enableManualDataInput)
            const SizedBox(
              height: 8,
            ),
          if (widget.enableManualDataInput)
            Text(
              context.t.favorite_groups.all_posts.toUpperCase(),
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
                      '${context.t.favorite_groups.initial_posts_hint}\n\n\n\n\n',
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
                  child: Text(context.t.favorite_groups.create_group_cancel),
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
                                    danbooruFavoriteGroupsProvider(
                                      config,
                                    ).notifier,
                                  )
                                  .create(
                                    context: context,
                                    initialIds: textController.text,
                                    name: value.text,
                                    isPrivate: isPrivate,
                                    onFailure: (message) => showErrorToast(
                                      context,
                                      message,
                                    ),
                                  );
                            } else {
                              ref
                                  .read(
                                    danbooruFavoriteGroupsProvider(
                                      config,
                                    ).notifier,
                                  )
                                  .edit(
                                    group: widget.initialData!,
                                    name: value.text,
                                    isPrivate: isPrivate,
                                    initialIds: textController.text,
                                    onFailure: (message) {
                                      showErrorToast(context, message);
                                    },
                                  );
                            }
                          }
                        : null,
                    child: Text(context.t.favorite_groups.create_group_confirm),
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
