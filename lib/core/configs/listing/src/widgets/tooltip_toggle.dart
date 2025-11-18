// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../posts/listing/types.dart';
import '../../../../widgets/widgets.dart';
import '../../../create/providers.dart';

class ListingTooltipToggle extends ConsumerWidget {
  const ListingTooltipToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tooltipMode = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select(
        (value) => TooltipDisplayMode.tryParse(value.tooltipDisplayMode),
      ),
    );

    return BooruSwitchListTile(
      title: Text(
        context.t.booru.listing.tooltip_on_hover_title,
      ),
      subtitle: Text(
        context.t.booru.listing.tooltip_on_hover_description,
      ),
      value: tooltipMode?.isEnabled ?? true,
      onChanged: (value) {
        final newMode = value
            ? TooltipDisplayMode.enabled
            : TooltipDisplayMode.disabled;
        ref.editNotifier.updateTooltipDisplayMode(newMode);
      },
    );
  }
}
