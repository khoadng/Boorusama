// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/settings/widgets/widgets.dart';
import 'package:boorusama/widgets/widgets.dart';

class BooruConfigListingView extends ConsumerWidget {
  const BooruConfigListingView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(
            editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
                .select((value) => value.listingTyped)) ??
        ListingConfigs.undefined();
    final enable = listing.enable;
    final settings = listing.settings;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text("Enable profile's specific settings"),
            subtitle: const Text(
              'Override the global settings for this the profile. If enabled, global settings will be ignored until this is disabled.',
            ),
            value: enable,
            onChanged: (value) => ref.editNotifier.updateListing(
              listing.copyWith(enable: value),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          const Divider(),
          GrayedOut(
            grayedOut: !enable,
            child: ImageListingSettingsSection(
              listing: settings,
              onUpdate: (value) => ref.editNotifier.updateListing(
                listing.copyWith(settings: value),
              ),
              itemPadding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
