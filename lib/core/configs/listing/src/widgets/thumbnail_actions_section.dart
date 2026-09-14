// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../create/providers.dart';
import '../types/thumbnail_actions.dart';

class ThumbnailActionsSection extends ConsumerWidget {
  const ThumbnailActionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.thumbnailActions),
    );
    final t = context.t.booru.listing;
    return Column(
      children: [
        _ActionTile(
          title: t.thumbnail_primary_action,
          value: actions.primary,
          options: const [null, ...ThumbnailAction.values],
          onChanged: (value) => ref.editNotifier.updateThumbnailActions(
            actions.withPrimary(value),
          ),
        ),
        KurumiGrayedOut(
          grayedOut: actions.primary == null,
          child: _ActionTile(
            title: t.thumbnail_secondary_action,
            description: t.thumbnail_secondary_action_description,
            value: actions.secondary,
            options: [
              null,
              ...ThumbnailAction.values.where(
                (value) => value != actions.primary,
              ),
            ],
            onChanged: (value) => ref.editNotifier.updateThumbnailActions(
              actions.withSecondary(value),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    this.description,
  });
  final String title;
  final String? description;
  final ThumbnailAction? value;
  final List<ThumbnailAction?> options;
  final ValueChanged<ThumbnailAction?> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    visualDensity: VisualDensity.compact,
    title: Text(title),
    subtitle: description == null ? null : Text(description!),
    trailing: KurumiOptionDropDownButton<ThumbnailAction?>(
      backgroundColor: Colors.transparent,
      alignment: AlignmentDirectional.centerStart,
      value: value,
      onChanged: onChanged,
      items: options
          .map(
            (action) => DropdownMenuItem(
              value: action,
              child: Text(switch (action) {
                null => context.t.post.action.none,
                ThumbnailAction.defaultAction =>
                  context.t.post.action.use_default,
                ThumbnailAction.bookmark => context.t.post.action.bookmark,
                ThumbnailAction.download => context.t.download.download,
                ThumbnailAction.artist => context.t.post.action.view_artist,
              }),
            ),
          )
          .toList(),
    ),
  );
}
