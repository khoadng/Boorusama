// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../settings/data.dart';
import '../../../settings/widgets.dart';
import '../../config/types.dart';
import '../../create/providers.dart';

class DefaultAutoFetchNotesSwitch extends ConsumerWidget {
  const DefaultAutoFetchNotesSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteBehavior = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider)).select(
        (value) => BooruConfigViewerNotesFetchBehavior.tryParse(
          value.viewerNotesFetchBehavior,
        ),
      ),
    );

    return SettingAnchor(
      id: SettingsIndex.viewer.autoFetchNotes.id,
      child: KurumiSwitchListTile(
        title: Text(
          SettingsIndex.viewer.autoFetchNotes.title(context),
        ),
        subtitle: Text(
          context.t.booru.viewer.auto_fetch_notes_description,
        ),
        value: noteBehavior?.isAuto ?? false,
        onChanged: (value) =>
            ref.editNotifier.updateViewerNotesFetchBehavior(value),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
