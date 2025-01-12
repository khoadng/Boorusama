// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../boorus/engine/engine.dart';
import '../../../boorus/engine/providers.dart';
import '../../../home/custom_home.dart';
import '../../../posts/details/custom_details.dart';
import '../../../premiums/premiums.dart';
import '../../../theme.dart';
import '../../../widgets/widgets.dart';
import '../booru_config.dart';
import '../data/booru_config_data.dart';
import 'appearance_details.dart';
import 'appearance_theme.dart';
import 'providers.dart';

class DefaultBooruConfigLayoutView extends ConsumerWidget {
  const DefaultBooruConfigLayoutView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BooruConfigLayoutView();
  }
}

class BooruConfigLayoutView extends ConsumerWidget {
  const BooruConfigLayoutView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final uiBuilder = ref.watchBooruBuilder(config.auth)?.postDetailsUIBuilder;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              children: [
                Expanded(
                  child: AppearanceConfigCard(
                    icon: const Icon(Symbols.color_lens),
                    title: 'Theme',
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => ProviderScope(
                            overrides: [
                              editBooruConfigIdProvider.overrideWithValue(
                                ref.watch(editBooruConfigIdProvider),
                              ),
                            ],
                            child: const ThemeConfigsPage(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                if (uiBuilder != null)
                  Expanded(
                    child: AppearanceConfigCard(
                      icon: const Icon(Symbols.info_rounded),
                      title: 'Details',
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => ProviderScope(
                              overrides: [
                                editBooruConfigIdProvider.overrideWithValue(
                                  ref.watch(editBooruConfigIdProvider),
                                ),
                                initialBooruConfigProvider.overrideWithValue(
                                  ref.watch(initialBooruConfigProvider),
                                ),
                              ],
                              child: _DetailsConfigPage(
                                uiBuilder: uiBuilder,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          const _HomeScreenSection(),
        ],
      ),
    );
  }
}

class _DetailsConfigPage extends ConsumerWidget {
  const _DetailsConfigPage({
    required this.uiBuilder,
  });

  final PostDetailsUIBuilder uiBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(
          editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
              .select((value) => value.layoutTyped),
        ) ??
        const LayoutConfigs.undefined();

    final details =
        layout.details ?? convertDetailsParts(uiBuilder.full.keys.toList());
    final previewDetails = layout.previewDetails ??
        convertDetailsParts(uiBuilder.preview.keys.toList());

    return DetailsConfigPage(
      layout: layout,
      details: details,
      previewDetails: previewDetails,
      uiBuilder: uiBuilder,
      onLayoutUpdated: (layout) {
        ref.editNotifier.updateLayout(layout);
      },
    );
  }
}

class _HomeScreenSection extends ConsumerWidget {
  const _HomeScreenSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final booruBuilder = ref.watchBooruBuilder(config.auth);
    final layout = ref.watch(
          editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
              .select((value) => value.layoutTyped),
        ) ??
        const LayoutConfigs.undefined();
    final data = booruBuilder?.customHomeViewBuilders ?? kDefaultAltHomeView;

    return PremiumInteractionBlock(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        title: const Text('Home screen'),
        subtitle: const Text(
          'Change the view of the home screen',
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
                  child: Text(_describeView(data, value)).tr(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _describeView(
    Map<CustomHomeViewKey, CustomHomeDataBuilder> data,
    CustomHomeViewKey viewKey,
  ) =>
      data[viewKey]?.displayName ?? 'Unknown';
}

class AppearanceConfigCard extends StatelessWidget {
  const AppearanceConfigCard({
    required this.icon,
    required this.title,
    required this.onPressed,
    super.key,
  });

  final Widget icon;
  final String title;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconTheme = theme.iconTheme;
    final borderRadius = BorderRadius.circular(16);

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Theme(
                  data: theme.copyWith(
                    iconTheme: iconTheme.copyWith(
                      size: 18,
                      color: theme.colorScheme.hintColor,
                    ),
                  ),
                  child: icon,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
