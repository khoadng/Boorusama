// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../settings/types.dart';
import '../../../../settings/widgets.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';
import '../widgets/thumbnail_actions_section.dart';
import '../widgets/tooltip_toggle.dart';

// Flutter imports:

class DefaultBooruConfigListingView extends ConsumerWidget {
  const DefaultBooruConfigListingView({
    super.key,
    this.tooltipToggle,
  });

  final Widget? tooltipToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BooruConfigListingView(
      tooltipToggle: tooltipToggle ?? const ListingTooltipToggle(),
    );
  }
}

class BooruConfigListingView extends ConsumerWidget {
  const BooruConfigListingView({
    this.tooltipToggle,
    super.key,
  });

  final Widget? tooltipToggle;

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
        data: Kurumi.themeOf(context).copyWith(
          listTileTheme: Kurumi.themeOf(context).listTileTheme.copyWith(
            contentPadding: EdgeInsets.zero,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ThumbnailActionsSection(),
            const Divider(),
            KurumiSwitchListTile(
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
            KurumiGrayedOut(
              grayedOut: !enable,
              child: ImageListingSettingsSection(
                listing: settings,
                onUpdate: (value) => ref.editNotifier.updateListing(
                  listing.copyWith(settings: value),
                ),
              ),
            ),
            if (tooltipToggle case final toggle?) ...[
              const Divider(),
              toggle,
            ],
          ],
        ),
      ),
    );
  }
}
