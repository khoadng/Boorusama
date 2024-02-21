// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_config_name_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/core/pages/boorus/widgets/selected_booru_chip.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';

typedef CreateConfigData = ({
  String configName,
});

class CreateBooruConfigScaffold extends ConsumerStatefulWidget {
  const CreateBooruConfigScaffold({
    super.key,
    this.backgroundColor,
    required this.config,
    required this.tabsBuilder,
    required this.allowSubmit,
    required this.submit,
  });

  final Color? backgroundColor;
  final BooruConfig config;
  final Map<String, Widget> Function(BuildContext context) tabsBuilder;
  final bool Function(CreateConfigData data) allowSubmit;
  final void Function(CreateConfigData data) submit;

  @override
  ConsumerState<CreateBooruConfigScaffold> createState() =>
      _CreateBooruConfigScaffoldState();
}

class _CreateBooruConfigScaffoldState
    extends ConsumerState<CreateBooruConfigScaffold> {
  late var configName = widget.config.name;

  @override
  Widget build(BuildContext context) {
    final tabMap = widget.tabsBuilder(context);

    return Material(
      color: widget.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SelectedBooruChip(
                    booruType: widget.config.booruType,
                    url: widget.config.url,
                  ),
                ),
                IconButton(
                  splashRadius: 20,
                  onPressed: context.navigator.pop,
                  icon: const Icon(Symbols.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CreateBooruConfigNameField(
              text: configName,
              onChanged: (value) => setState(() => configName = value),
            ),
            Expanded(
              child: DefaultTabController(
                length: tabMap.length,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TabBar(
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      indicatorColor: context.colorScheme.onBackground,
                      labelColor: context.colorScheme.onBackground,
                      unselectedLabelColor:
                          context.colorScheme.onBackground.withOpacity(0.5),
                      tabs: [
                        for (final tab in tabMap.keys) Tab(text: tab),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (final tab in tabMap.values) tab,
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: CreateBooruSubmitButton(
                        onSubmit: widget.allowSubmit((configName: configName,))
                            ? () => widget.submit((configName: configName,))
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
