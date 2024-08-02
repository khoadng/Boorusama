// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/string.dart';
import '../users/users.dart';
import 'favorite_groups.dart';

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
    final config = ref.readConfig;

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
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              BooruTextField(
                autofocus: true,
                controller: nameController,
                maxLines: null,
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
                  style: context.textTheme.titleMedium?.copyWith(
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
                    maxLines: null,
                    decoration: InputDecoration(
                      hintMaxLines: 6,
                      hintText:
                          '${'favorite_groups.initial_posts_hint'.tr()}\n\n\n\n\n',
                    ),
                  ),
                ),
              PrivacyToggle(
                isPrivate: isPrivate,
                onChanged: (value) => setState(() => isPrivate = value),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                child: OverflowBar(
                  alignment: MainAxisAlignment.end,
                  spacing: 4,
                  children: [
                    TextButton(
                      onPressed: () => context.navigator.pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: context.colorScheme.onSurface,
                      ),
                      child: const Text('favorite_groups.create_group_cancel')
                          .tr(),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: nameController,
                      builder: (context, value, child) => FilledButton(
                        onPressed: nameController.text.isNotEmpty
                            ? () {
                                context.navigator.pop();
                                if (widget.initialData == null) {
                                  ref
                                      .read(
                                          danbooruFavoriteGroupsProvider(config)
                                              .notifier)
                                      .create(
                                        initialIds: textController.text,
                                        name: value.text,
                                        isPrivate: isPrivate,
                                        onFailure: (message, translatable) =>
                                            showErrorToast(
                                          translatable ? message.tr() : message,
                                        ),
                                      );
                                } else {
                                  ref
                                      .read(
                                          danbooruFavoriteGroupsProvider(config)
                                              .notifier)
                                      .edit(
                                        group: widget.initialData!,
                                        name: value.text,
                                        isPrivate: isPrivate,
                                        initialIds: textController.text,
                                        onFailure: (message, _) {
                                          showErrorToast(message);
                                        },
                                      );
                                }
                              }
                            : null,
                        child:
                            const Text('favorite_groups.create_group_confirm')
                                .tr(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyToggle extends ConsumerWidget {
  const PrivacyToggle({
    super.key,
    required this.isPrivate,
    required this.onChanged,
  });

  final bool isPrivate;
  final void Function(bool value) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.readConfig;
    final currentUser = ref.watch(danbooruCurrentUserProvider(config));

    return BooruAnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: const Text('favorite_groups.is_private_group_option').tr(),
        trailing: Switch(
          value: isPrivate,
          onChanged: onChanged,
        ),
      ),
      crossFadeState: currentUser.maybeWhen(
        data: (user) => user != null && isBooruGoldPlusAccount(user.level)
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        orElse: () => CrossFadeState.showFirst,
      ),
      duration: const Duration(milliseconds: 150),
    );
  }
}
