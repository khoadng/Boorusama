// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../settings/settings.dart';
import '../../../settings/widgets.dart';
import '../../../widgets/widgets.dart';
import '../../config/types.dart';
import '../../create/providers.dart';
import 'create_booru_image_details_resolution_option_tile.dart';

class BooruConfigViewerView extends ConsumerWidget {
  const BooruConfigViewerView({
    super.key,
    this.postDetailsResolution,
    this.autoLoadNotes,
  });

  final Widget? postDetailsResolution;
  final Widget? autoLoadNotes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider)),
    );
    final viewerConfig = config.viewerTyped;
    final viewerEnabled = viewerConfig?.enable ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Theme(
        data: Theme.of(context).copyWith(
          listTileTheme: Theme.of(context).listTileTheme.copyWith(
            contentPadding: EdgeInsets.zero,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (postDetailsResolution != null)
              postDetailsResolution!
            else
              const DefaultImageDetailsQualityTile(),
            if (autoLoadNotes != null) autoLoadNotes!,
            const SizedBox(height: 16),
            const Divider(),
            BooruSwitchListTile(
              title: Text(
                context.t.booru.listing.enable_profile_specific_settings,
              ),
              subtitle: Text(
                context
                    .t
                    .booru
                    .listing
                    .enable_profile_specific_settings_description,
              ),
              value: viewerEnabled,
              onChanged: (value) {
                if (value) {
                  ref.editNotifier.updateViewerConfigs(
                    ViewerConfigs(
                      settings: Settings.defaultSettings.viewer,
                      enable: true,
                    ),
                  );
                } else {
                  ref.editNotifier.updateViewerConfigs(null);
                }
              },
            ),
            GrayedOut(
              grayedOut: !viewerEnabled,
              child: ImageViewerSettingsSection(
                viewer:
                    viewerConfig?.settings ?? Settings.defaultSettings.viewer,
                onUpdate: (viewerSettings) {
                  final currentViewerConfig = config.viewerTyped;
                  ref.editNotifier.updateViewerConfigs(
                    ViewerConfigs(
                      settings: viewerSettings,
                      enable: currentViewerConfig?.enable ?? true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DefaultImageDetailsQualityTile extends ConsumerWidget {
  const DefaultImageDetailsQualityTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruGeneralPostDetailsResolutionOptionTile(
      value: ref.watch(
        editBooruConfigProvider(
          ref.watch(editBooruConfigIdProvider),
        ).select((value) => value.imageDetaisQuality),
      ),
      onChanged: (value) => ref.editNotifier.updateImageDetailsQuality(value),
    );
  }
}
