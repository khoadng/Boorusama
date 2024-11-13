// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'create.dart';

class DefaultBooruConfigLayoutView extends StatelessWidget {
  const DefaultBooruConfigLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return BooruConfigLayoutView(
      altHomeView: kDefaultAltHomeView.keys.toList(),
      decribeView: (viewKey) =>
          kDefaultAltHomeView[viewKey]?.displayName ?? 'Unknown',
    );
  }
}

class BooruConfigLayoutView extends ConsumerWidget {
  const BooruConfigLayoutView({
    super.key,
    required this.altHomeView,
    required this.decribeView,
  });

  final List<CustomHomeViewKey> altHomeView;
  final String Function(CustomHomeViewKey viewKey) decribeView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(
            editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
                .select((value) => value.layoutTyped)) ??
        LayoutConfigs.undefined();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text("Home screen"),
            subtitle: const Text(
              'Change the view of the home screen',
            ),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: layout.home,
              onChanged: (value) => ref.editNotifier.updateLayout(
                layout.copyWith(home: value),
              ),
              items: altHomeView
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(decribeView(value)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
