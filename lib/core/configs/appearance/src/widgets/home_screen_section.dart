// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../home/types.dart';
import '../../../../premiums/widgets.dart';
import '../../../../widgets/widgets.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';

class HomeScreenSection extends ConsumerWidget {
  const HomeScreenSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final booruBuilder = ref.watch(booruBuilderProvider(config.auth));
    final layout =
        ref.watch(
          editBooruConfigProvider(
            ref.watch(editBooruConfigIdProvider),
          ).select((value) => value.layoutTyped),
        ) ??
        const LayoutConfigs.undefined();
    final data = booruBuilder?.customHomeViewBuilders ?? kDefaultAltHomeView;

    return PremiumInteractionBlock(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        title: Text(context.t.booru.appearance.home_screen),
        subtitle: Text(
          context.t.booru.appearance.home_screen_description,
        ),
        trailing: OptionDropDownButton(
          alignment: AlignmentDirectional.centerStart,
          value: layout.home,
          onChanged: (value) => ref.editNotifier.updateLayout(
            layout.copyWith(home: () => value),
          ),
          items: data.keys
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(_describeView(context, data, value)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _describeView(
    BuildContext context,
    Map<CustomHomeViewKey, CustomHomeDataBuilder> data,
    CustomHomeViewKey viewKey,
  ) => data[viewKey]?.displayName(context) ?? 'Unknown'.hc;
}
