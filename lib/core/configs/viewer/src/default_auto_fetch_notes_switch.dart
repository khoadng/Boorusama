// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../config/types.dart';
import '../../create/providers.dart';

class DefaultAutoFetchNotesSwitch extends ConsumerWidget {
  const DefaultAutoFetchNotesSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoLoadNotes = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider)).select(
        (value) =>
            value.viewerNotesFetchBehaviorTyped ==
            BooruConfigViewerNotesFetchBehavior.auto,
      ),
    );

    return SwitchListTile(
      title: Text('Auto-fetch notes'.hc),
      subtitle: Text(
        'Automatically fetch and display notes whenever possible.'.hc,
      ),
      value: autoLoadNotes,
      onChanged: (value) =>
          ref.editNotifier.updateViewerNotesFetchBehavior(value),
      contentPadding: EdgeInsets.zero,
    );
  }
}
