// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class EditFavoriteGroupDialog extends ConsumerStatefulWidget {
  const EditFavoriteGroupDialog({
    super.key,
    required this.title,
    this.padding,
    this.initialData,
    this.enableManualDataInput = true,
  });

  final double? padding;
  final String title;
  final FavoriteGroup? initialData;
  final bool enableManualDataInput;

  @override
  ConsumerState<EditFavoriteGroupDialog> createState() =>
      _EditFavoriteGroupDialogState();
}

class _EditFavoriteGroupDialogState
    extends ConsumerState<EditFavoriteGroupDialog> {
  final textController = TextEditingController();
  final nameController = TextEditingController();
  bool isPrivate = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      textController.text = widget.initialData!.postIds.join(' ');
      nameController.text =
          widget.initialData!.name.replaceUnderscoreWithSpace();
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
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  widget.title,
                  style: context.textTheme.titleLarge,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'favorite_groups.group_name'.tr().toUpperCase(),
                  style: context.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextField(
                autofocus: true,
                controller: nameController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'favorite_groups.group_name_hint'.tr(),
                  filled: true,
                  fillColor: context.theme.cardColor,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                      color: context.colorScheme.secondary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              if (widget.enableManualDataInput)
                const SizedBox(
                  height: 8,
                ),
              if (widget.enableManualDataInput)
                Text(
                  'favorite_groups.all_posts'.tr().toUpperCase(),
                  style: context.textTheme.titleMedium!.copyWith(
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
                  child: TextField(
                    controller: textController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintMaxLines: 6,
                      hintText:
                          '${'favorite_groups.initial_posts_hint'.tr()}\n\n\n\n\n',
                      filled: true,
                      fillColor: context.theme.cardColor,
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                          color: context.colorScheme.secondary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
              PrivacyToggle(
                isPrivate: isPrivate,
                onChanged: (value) => setState(() => isPrivate = value),
              ),
              ButtonBar(
                children: [
                  TextButton(
                    onPressed: () => context.navigator.pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colorScheme.onBackground,
                    ),
                    child:
                        const Text('favorite_groups.create_group_cancel').tr(),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: nameController,
                    builder: (context, value, child) => ElevatedButton(
                      onPressed: nameController.text.isNotEmpty
                          ? () {
                              context.navigator.pop();
                              if (widget.initialData == null) {
                                ref
                                    .read(
                                        danbooruFavoriteGroupsProvider.notifier)
                                    .create(
                                      initialIds: textController.text,
                                      name: value.text,
                                      isPrivate: isPrivate,
                                      onFailure: (message, translatable) =>
                                          showSimpleSnackBar(
                                        context: context,
                                        content: translatable
                                            ? Text(message).tr()
                                            : Text(message),
                                      ),
                                    );
                              } else {
                                ref
                                    .read(
                                        danbooruFavoriteGroupsProvider.notifier)
                                    .edit(
                                      group: widget.initialData!,
                                      name: value.text,
                                      isPrivate: isPrivate,
                                      initialIds: textController.text,
                                      onFailure: (message, _) {
                                        showSimpleSnackBar(
                                          context: context,
                                          content: Text(message.toString()),
                                        );
                                      },
                                    );
                              }
                            }
                          : null,
                      child: const Text('favorite_groups.create_group_confirm')
                          .tr(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyToggle extends ConsumerWidget {
  const PrivacyToggle(
      {super.key, required this.isPrivate, required this.onChanged});

  final bool isPrivate;
  final void Function(bool value) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(danbooruCurrentUserProvider);

    return AnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: const Text('favorite_groups.is_private_group_option').tr(),
        trailing: Switch.adaptive(
          value: isPrivate,
          onChanged: onChanged,
        ),
      ),
      crossFadeState:
          currentUser != null && isBooruGoldPlusAccount(currentUser.level)
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 150),
    );
  }
}
