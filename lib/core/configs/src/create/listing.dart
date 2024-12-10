// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/gestures.dart';
import '../../../../widgets/widgets.dart';
import '../../../settings.dart';
import '../../../settings/pages.dart';
import '../data/booru_config_data.dart';
import 'providers.dart';

const kDefaultPreviewImageButtonAction = {
  '',
  null,
  kToggleBookmarkAction,
  kDownloadAction,
  kViewArtistAction,
};

class DefaultBooruConfigListingView extends ConsumerWidget {
  const DefaultBooruConfigListingView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BooruConfigListingView(
      postPreviewQuickActionButtonActions: kDefaultPreviewImageButtonAction,
      describePostPreviewQuickAction: null,
    );
  }
}

class BooruConfigListingView extends ConsumerWidget {
  const BooruConfigListingView({
    super.key,
    required this.postPreviewQuickActionButtonActions,
    required this.describePostPreviewQuickAction,
  });

  final Set<String?> postPreviewQuickActionButtonActions;
  final String Function(String? action)? describePostPreviewQuickAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(
          editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
              .select((value) => value.listingTyped),
        ) ??
        ListingConfigs.undefined();
    final enable = listing.enable;
    final settings = listing.settings;

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
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              title: const Text("Thumbnail's button"),
              subtitle: const Text(
                'Change the default button at the right bottom of the thumbnail.',
              ),
              trailing: OptionDropDownButton(
                alignment: AlignmentDirectional.centerStart,
                value: ref.watch(
                  editBooruConfigProvider(
                    ref.watch(editBooruConfigIdProvider),
                  ).select((value) => value.defaultPreviewImageButtonAction),
                ),
                onChanged: (value) => ref.editNotifier
                    .updateDefaultPreviewImageButtonAction(value),
                items: postPreviewQuickActionButtonActions
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          describePostPreviewQuickAction != null
                              ? describePostPreviewQuickAction!(value)
                              : describeImagePreviewQuickAction(value),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text("Enable profile's specific settings"),
              subtitle: const Text(
                'Override the global settings for this the profile. If enabled, global settings will be ignored until this is disabled.',
              ),
              value: enable,
              onChanged: (value) => ref.editNotifier.updateListing(
                listing.copyWith(enable: value),
              ),
            ),
            GrayedOut(
              grayedOut: !enable,
              child: ImageListingSettingsSection(
                listing: settings,
                onUpdate: (value) => ref.editNotifier.updateListing(
                  listing.copyWith(settings: value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
