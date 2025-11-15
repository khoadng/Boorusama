// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../settings/types.dart';
import '../../../../settings/widgets.dart';
import '../../../../widgets/widgets.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';
import '../../../gesture/types.dart';

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
    required this.postPreviewQuickActionButtonActions,
    required this.describePostPreviewQuickAction,
    super.key,
  });

  final Set<String?> postPreviewQuickActionButtonActions;
  final String Function(String? action)? describePostPreviewQuickAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing =
        ref.watch(
          editBooruConfigProvider(
            ref.watch(editBooruConfigIdProvider),
          ).select((value) => value.listingTyped),
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
              title: Text(context.t.booru.listing.thumbnail_button),
              subtitle: Text(
                context.t.booru.listing.thumbnail_button_description,
              ),
              trailing: OptionDropDownButton(
                backgroundColor: Colors.transparent,
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
                              : describeImagePreviewQuickAction(value, context),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
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
