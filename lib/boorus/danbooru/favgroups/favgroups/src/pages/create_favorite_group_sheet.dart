// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/configs/config/types.dart';
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
  var _loading = false;

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

  Future<void> _doEdit({
    required BooruConfigSearch config,
    required DanbooruFavoriteGroup group,
    required String name,
    List<int>? postIds,
  }) async {
    setState(() => _loading = true);

    final success = await ref
        .read(danbooruFavoriteGroupsProvider(config).notifier)
        .edit(
          group: group,
          name: name,
          isPrivate: isPrivate,
          postIds: postIds,
          onFailure: (message) {
            if (mounted) showErrorToast(context, message);
          },
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() => _loading = false);
    }
  }

  void _confirmAndEdit({
    required BuildContext context,
    required BooruConfigSearch config,
    required DanbooruFavoriteGroup group,
    required String name,
  }) {
    final input = textController.text;
    final parts = input.split(' ').where((e) => e.isNotEmpty);
    final invalidParts = parts.where((e) => int.tryParse(e) == null).toList();

    if (invalidParts.isNotEmpty) {
      showErrorToast(
        context,
        context.t.favorite_groups.invalid_post_ids.replaceAll(
          '{0}',
          invalidParts.join(', '),
        ),
      );
      return;
    }

    final newIds = _parsePostIds(input).toSet();
    final oldIds = group.postIds.toSet();

    final added = newIds.difference(oldIds);
    final removed = oldIds.difference(newIds);

    if (added.isEmpty && removed.isEmpty) {
      _doEdit(config: config, group: group, name: name);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.t.favorite_groups.confirm_edit_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (added.isNotEmpty)
              Text(
                dialogContext.t.favorite_groups.confirm_edit_adding(
                  n: added.length,
                ),
              ),
            if (removed.isNotEmpty)
              Text(
                dialogContext.t.favorite_groups.confirm_edit_removing(
                  n: removed.length,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(dialogContext.t.generic.action.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _doEdit(
                config: config,
                group: group,
                name: name,
                postIds: newIds.toList(),
              );
            },
            child: Text(dialogContext.t.generic.action.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigSearch;

    return _SheetFrame(
      loading: _loading,
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
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurface,
                  ),
                  child: Text(
                    context.t.favorite_groups.create_group_cancel,
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: nameController,
                  builder: (context, value, child) => FilledButton(
                    onPressed: nameController.text.isNotEmpty && !_loading
                        ? () {
                            if (widget.initialData == null) {
                              Navigator.of(context).pop();
                              ref
                                  .read(
                                    danbooruFavoriteGroupsProvider(
                                      config,
                                    ).notifier,
                                  )
                                  .create(
                                    context: context,
                                    initialPostIds: _parsePostIds(
                                      textController.text,
                                    ),
                                    name: value.text,
                                    isPrivate: isPrivate,
                                    onFailure: (message) => showErrorToast(
                                      context,
                                      message,
                                    ),
                                  );
                            } else {
                              _confirmAndEdit(
                                context: context,
                                config: config,
                                group: widget.initialData!,
                                name: value.text,
                              );
                            }
                          }
                        : null,
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            context.t.favorite_groups.create_group_confirm,
                          ),
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

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({
    required this.loading,
    required this.child,
  });

  final bool loading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !loading,
      child: AbsorbPointer(
        absorbing: loading,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: child,
        ),
      ),
    );
  }
}

List<int> _parsePostIds(String input) =>
    input.split(' ').map((e) => int.tryParse(e)).nonNulls.toList();
