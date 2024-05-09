// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/selected_booru_chip.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'configs.dart';

const kDefaultPreviewImageButtonAction = {
  '',
  null,
  kToggleBookmarkAction,
  kDownloadAction,
  kViewArtistAction,
};

class CreateBooruConfigScaffold extends ConsumerWidget {
  const CreateBooruConfigScaffold({
    super.key,
    this.backgroundColor,
    required this.tabsBuilder,
    required this.isNewConfig,
    this.authTab,
    this.postDetailsResolution,
    this.hasDownloadTab = false,
    this.hasRatingFilter = false,
    this.miscOptions,
    this.postDetailsGestureActions = kDefaultGestureActions,
    this.postPreviewQuickActionButtonActions = kDefaultPreviewImageButtonAction,
    this.describePostDetailsAction,
    this.describePostPreviewQuickAction,
    required this.submitButtonBuilder,
  });

  final Color? backgroundColor;
  final Map<String, Widget> Function(BuildContext context) tabsBuilder;

  final Widget? authTab;

  final Widget? postDetailsResolution;

  final bool hasDownloadTab;
  final bool hasRatingFilter;

  final List<Widget>? miscOptions;

  final Set<String?> postDetailsGestureActions;
  final String Function(String? action)? describePostDetailsAction;

  final Set<String?> postPreviewQuickActionButtonActions;
  final String Function(String? action)? describePostPreviewQuickAction;
  final bool isNewConfig;

  final Widget Function(BooruConfigData data) submitButtonBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);

    final tabMap = {
      if (authTab != null) 'booru.authentication': authTab!,
      if (hasDownloadTab)
        'booru.download': BooruConfigDownloadView(config: config),
      ...tabsBuilder(context),
      'booru.gestures': BooruConfigGesturesView(
        postDetailsGestureActions: postDetailsGestureActions,
        describePostDetailsAction: describePostDetailsAction,
      ),
      'booru.misc': BooruConfigMiscView(
        hasRatingFilter: hasRatingFilter,
        postDetailsGestureActions: postDetailsGestureActions,
        postPreviewQuickActionButtonActions:
            postPreviewQuickActionButtonActions,
        describePostPreviewQuickAction: describePostPreviewQuickAction,
        describePostDetailsAction: describePostDetailsAction,
        config: config,
        postDetailsResolution: postDetailsResolution,
        miscOptions: miscOptions,
      ),
    };

    return Material(
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SelectedBooruChip(
                    booruType: config.booruType,
                    url: config.url,
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
            const BooruConfigNameField(),
            Expanded(
              child: DefaultTabController(
                length: tabMap.length,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4),
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
                        for (final tab in tabMap.keys) Tab(text: tab.tr()),
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
                      child: Column(
                        children: [
                          if (isNewConfig)
                            Text(
                              'Not sure? Leave it as it is, you can change it later.',
                              style: context.textTheme.titleSmall?.copyWith(
                                color: context.theme.hintColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: BooruConfigSubmitButton(
                                  builder: submitButtonBuilder,
                                ),
                              ),
                            ],
                          ),
                        ],
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

class BooruConfigSettingsHeader extends StatelessWidget {
  const BooruConfigSettingsHeader({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        label,
        style: TextStyle(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
