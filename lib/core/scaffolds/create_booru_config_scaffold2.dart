// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_config_name_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_post_details_resolution_option_tile.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_rating_options_tile.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/core/pages/boorus/widgets/custom_download_file_name_section.dart';
import 'package:boorusama/core/pages/boorus/widgets/selected_booru_chip.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class DefaultBooruConfigSubmitButton extends ConsumerWidget {
  const DefaultBooruConfigSubmitButton({
    super.key,
    required this.config,
    required this.dataBuilder,
    required this.enable,
  });

  final bool enable;
  final BooruConfig config;
  final BooruConfigData Function() dataBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruSubmitButton(
      onSubmit: enable
          ? () {
              final data = dataBuilder();

              ref
                  .read(booruConfigProvider.notifier)
                  .addOrUpdateUsingBooruConfigData(
                    config: config,
                    newConfig: data,
                  );

              context.navigator.pop();
            }
          : null,
    );
  }
}

const kDefaultPreviewImageButtonAction = {
  '',
  null,
  kToggleBookmarkAction,
  kDownloadAction,
  kViewArtistAction,
};

class AuthConfigData extends Equatable {
  const AuthConfigData({
    required this.login,
    required this.apiKey,
  });

  AuthConfigData.fromConfig(BooruConfigData config)
      : login = config.login,
        apiKey = config.apiKey;

  final String login;
  final String apiKey;

  AuthConfigData copyWith({
    String? login,
    String? apiKey,
  }) {
    return AuthConfigData(
      login: login ?? this.login,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  @override
  List<Object> get props => [login, apiKey];
}

extension AuthConfigDataX on AuthConfigData {
  bool get isEmpty => login.isEmpty && apiKey.isEmpty;

  bool get isValid => isEmpty || (login.isNotEmpty && apiKey.isNotEmpty);
}

final initialBooruConfigProvider = Provider.autoDispose<BooruConfig>(
  (ref) => throw UnimplementedError(),
);

final booruConfigDataProvider = StateProvider.autoDispose<BooruConfigData>(
  (ref) => ref.watch(initialBooruConfigProvider).toBooruConfigData(),
  dependencies: [initialBooruConfigProvider],
);

final authConfigDataProvider = StateProvider.autoDispose<AuthConfigData>(
  (ref) => ref.watch(booruConfigDataProvider.select(AuthConfigData.fromConfig)),
  dependencies: [booruConfigDataProvider],
);

final postGesturesConfigDataProvider =
    StateProvider.autoDispose<PostGestureConfig?>(
  (ref) => ref.watch(
      booruConfigDataProvider.select((value) => value.postGesturesConfigTyped)),
  dependencies: [booruConfigDataProvider],
);

final defaultPreviewImageButtonActionProvider =
    StateProvider.autoDispose<String?>(
  (ref) => ref.watch(booruConfigDataProvider
      .select((value) => value.defaultPreviewImageButtonAction)),
  dependencies: [booruConfigDataProvider],
);

final granularRatingFilterProvider = StateProvider.autoDispose<Set<Rating>?>(
  (ref) => ref.watch(booruConfigDataProvider
      .select((value) => value.granularRatingFilterTyped)),
  dependencies: [booruConfigDataProvider],
);

final defaultImageDetailsQualityProvider = StateProvider.autoDispose<String?>(
  (ref) => ref.watch(
      booruConfigDataProvider.select((value) => value.imageDetaisQuality)),
  dependencies: [booruConfigDataProvider],
);

final ratingFilterProvider =
    StateProvider.autoDispose<BooruConfigRatingFilter?>(
  (ref) => ref.watch(
      booruConfigDataProvider.select((value) => value.ratingFilterTyped)),
  dependencies: [booruConfigDataProvider],
);

final customBulkDownloadFileNameFormatProvider =
    StateProvider.autoDispose<String?>(
  (ref) => ref.watch(booruConfigDataProvider
      .select((value) => value.customBulkDownloadFileNameFormat)),
  dependencies: [booruConfigDataProvider],
);
final customDownloadFileNameFormatProvider = StateProvider.autoDispose<String?>(
  (ref) => ref.watch(booruConfigDataProvider
      .select((value) => value.customDownloadFileNameFormat)),
  dependencies: [booruConfigDataProvider],
);

final configNameProvider = StateProvider.autoDispose<String>(
  (ref) => ref.watch(booruConfigDataProvider.select((value) => value.name)),
  dependencies: [booruConfigDataProvider],
);

extension UpdateDataX on WidgetRef {
  void updateAuthConfigData(
    AuthConfigData data,
  ) =>
      read(authConfigDataProvider.notifier).state = data;

  void updateGesturesConfigData(
    PostGestureConfig? data,
  ) =>
      read(postGesturesConfigDataProvider.notifier).state = data;

  void updateRatingFilter(BooruConfigRatingFilter? data) =>
      read(ratingFilterProvider.notifier).state = data;

  void updateGranularRatingFilter(Set<Rating>? data) =>
      read(granularRatingFilterProvider.notifier).state = data;

  void updateDefaultPreviewImageButtonAction(String? data) =>
      read(defaultPreviewImageButtonActionProvider.notifier).state = data;

  void updateImageDetailsQuality(String? data) =>
      read(defaultImageDetailsQualityProvider.notifier).state = data;

  void updateCustomBulkDownloadFileNameFormat(String? data) =>
      read(customBulkDownloadFileNameFormatProvider.notifier).state = data;

  void updateCustomDownloadFileNameFormat(String? data) =>
      read(customDownloadFileNameFormatProvider.notifier).state = data;

  void updateName(String data) =>
      read(configNameProvider.notifier).state = data;
}

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
                              )),
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

class BooruConfigSubmitButton extends ConsumerWidget {
  const BooruConfigSubmitButton({
    super.key,
    required this.builder,
  });

  final Widget Function(BooruConfigData data) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(booruConfigDataProvider);
    final defaultImageDetailsQuality =
        ref.watch(defaultImageDetailsQualityProvider);
    final ratingFilter = ref.watch(ratingFilterProvider);
    final granularRatingFilter = ref.watch(granularRatingFilterProvider);
    final customDownloadFileNameFormat =
        ref.watch(customDownloadFileNameFormatProvider);
    final customBulkDownloadFileNameFormat =
        ref.watch(customBulkDownloadFileNameFormatProvider);
    final configName = ref.watch(configNameProvider);
    final defaultPreviewImageButtonAction =
        ref.watch(defaultPreviewImageButtonActionProvider);

    return builder(data.copyWith(
      granularRatingFilter: () => granularRatingFilter,
      ratingFilter: ratingFilter,
      imageDetaisQuality: () => defaultImageDetailsQuality,
      customDownloadFileNameFormat: () => customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: () => customBulkDownloadFileNameFormat,
      defaultPreviewImageButtonAction: () => defaultPreviewImageButtonAction,
      name: configName,
    ));
  }
}

class BooruConfigDownloadView extends ConsumerWidget {
  const BooruConfigDownloadView({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customDownloadFileNameFormat =
        ref.watch(customDownloadFileNameFormatProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomDownloadFileNameSection(
            config: config,
            format: customDownloadFileNameFormat,
            onIndividualDownloadChanged: (value) =>
                ref.updateCustomDownloadFileNameFormat(value),
            onBulkDownloadChanged: (value) =>
                ref.updateCustomBulkDownloadFileNameFormat(value),
          ),
        ],
      ),
    );
  }
}

class BooruConfigMiscView extends ConsumerWidget {
  const BooruConfigMiscView({
    super.key,
    required this.hasRatingFilter,
    required this.postDetailsGestureActions,
    required this.postPreviewQuickActionButtonActions,
    required this.describePostPreviewQuickAction,
    this.describePostDetailsAction,
    this.miscOptions,
    required this.config,
    this.postDetailsResolution,
  });

  final BooruConfig config;
  final bool hasRatingFilter;
  final Set<String?> postDetailsGestureActions;
  final String Function(String? action)? describePostDetailsAction;

  final Set<String?> postPreviewQuickActionButtonActions;
  final String Function(String? action)? describePostPreviewQuickAction;

  final List<Widget>? miscOptions;
  final Widget? postDetailsResolution;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text("Thumbnail's button"),
            subtitle: const Text(
              'Change the default button at the right bottom of the thumbnail.',
            ),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: ref.watch(defaultPreviewImageButtonActionProvider),
              onChanged: (value) =>
                  ref.updateDefaultPreviewImageButtonAction(value),
              items: postPreviewQuickActionButtonActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(describePostPreviewQuickAction != null
                            ? describePostPreviewQuickAction!(value)
                            : describeImagePreviewQuickAction(value)),
                      ))
                  .toList(),
            ),
          ),
          if (hasRatingFilter) ...[
            CreateBooruRatingOptionsTile(
              config: config,
              initialGranularRatingFilters:
                  ref.watch(granularRatingFilterProvider),
              value: ref.watch(ratingFilterProvider),
              onChanged: (value) =>
                  value != null ? ref.updateRatingFilter(value) : null,
              onGranularRatingFiltersChanged: (value) =>
                  ref.updateGranularRatingFilter(value),
            ),
          ],
          if (postDetailsResolution != null)
            postDetailsResolution!
          else
            DefaultImageDetailsQualityTile(config: config),
          if (miscOptions != null) ...miscOptions!,
        ],
      ),
    );
  }
}

class BooruConfigNameField extends ConsumerWidget {
  const BooruConfigNameField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruConfigNameField(
      text: ref.watch(configNameProvider),
      onChanged: (value) => ref.updateName(value),
    );
  }
}

class DefaultImageDetailsQualityTile extends ConsumerWidget {
  const DefaultImageDetailsQualityTile({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruGeneralPostDetailsResolutionOptionTile(
      value: ref.watch(defaultImageDetailsQualityProvider),
      onChanged: (value) => ref.updateImageDetailsQuality(value),
    );
  }
}

class BooruConfigGesturesView extends ConsumerWidget {
  const BooruConfigGesturesView({
    super.key,
    required this.postDetailsGestureActions,
    this.describePostDetailsAction,
  });

  final Set<String?> postDetailsGestureActions;
  final String Function(String? action)? describePostDetailsAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postGesturesConfigTyped = ref.watch(postGesturesConfigDataProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BooruConfigSettingsHeader(label: 'Image viewer'),
          WarningContainer(
            contentBuilder: (_) => const Text(
              'Images only, not applicable to videos.',
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text('gestures.swipe_down').tr(),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.fullview?.swipeDown,
              onChanged: (value) {
                ref.updateGesturesConfigData(
                  postGesturesConfigTyped?.withFulviewSwipeDown(value),
                );
              },
              items: postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value)),
                      ))
                  .toList(),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text('gestures.double_tap').tr(),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.fullview?.doubleTap,
              onChanged: (value) {
                ref.updateGesturesConfigData(
                  postGesturesConfigTyped?.withFulviewDoubleTap(value),
                );
              },
              items: postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value)),
                      ))
                  .toList(),
            ),
          ),
          //long press
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text('gestures.long_press').tr(),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.fullview?.longPress,
              onChanged: (value) {
                ref.updateGesturesConfigData(
                  postGesturesConfigTyped?.withFulviewLongPress(value),
                );
              },
              items: postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value)),
                      ))
                  .toList(),
            ),
          ),

          const Divider(thickness: 0.5, height: 32),
          const BooruConfigSettingsHeader(label: 'Image preview'),
          // tap
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text('gestures.tap').tr(),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.preview?.tap,
              onChanged: (value) {
                ref.updateGesturesConfigData(
                  postGesturesConfigTyped?.withPreviewTap(value),
                );
              },
              items: postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value)),
                      ))
                  .toList(),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text('gestures.long_press').tr(),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.preview?.longPress,
              onChanged: (value) {
                ref.updateGesturesConfigData(
                  postGesturesConfigTyped?.withPreviewLongPress(value),
                );
              },
              items: postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Override the default gestures for this profile, select "None" to keep the original behavior.',
            style: ref.context.textTheme.titleSmall?.copyWith(
              color: ref.context.theme.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
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
