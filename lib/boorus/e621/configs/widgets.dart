// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/create/providers.dart';
import '../../../core/configs/create/widgets.dart';
import '../../../core/configs/search/widgets.dart';
import '../../../core/configs/viewer/widgets.dart';
import '../../../core/widgets/widgets.dart';
import '../posts/types.dart';

class CreateE621ConfigPage extends StatelessWidget {
  const CreateE621ConfigPage({
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;

  @override
  Widget build(BuildContext context) {
    return CreateBooruConfigScaffold(
      initialTab: initialTab,
      backgroundColor: backgroundColor,
      authTab: const DefaultBooruAuthConfigView(),
      searchTab: const DefaultBooruConfigSearchView(
        hasRatingFilter: true,
      ),
      imageViewerTab: const BooruConfigViewerView(
        autoLoadNotes: DefaultAutoFetchNotesSwitch(),
        videoQuality: E621VideoQualityOptionTile(),
      ),
    );
  }
}

class E621VideoQualityOptionTile extends ConsumerWidget {
  const E621VideoQualityOptionTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quality = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.videoQuality),
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: Text(context.t.video_player.video_quality),
      trailing: OptionDropDownButton(
        alignment: AlignmentDirectional.centerStart,
        value: E621VideoVariantType.tryParse(quality),
        onChanged: (value) => ref.editNotifier.updateVideoQuality(
          value?.value,
        ),
        items: [
          for (final quality in [null, ...E621VideoVariantType.values])
            DropdownMenuItem(
              value: E621VideoVariantType.tryParse(quality?.value),
              child: Text(
                quality?.getLabel(context) ??
                    context.t.video_player.video_qualities.auto,
              ),
            ),
        ],
      ),
    );
  }
}
