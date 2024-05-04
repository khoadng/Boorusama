// Flutter imports:
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Package imports:
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

class CreateConfigData extends Equatable {
  const CreateConfigData({
    required this.configName,
    required this.customDownloadFileNameFormat,
    required this.customBulkDownloadFileNameFormat,
    required this.granularRatingFilters,
    required this.ratingFilter,
    required this.imageDetaisQuality,
    required this.postGestures,
    required this.defaultPreviewImageButtonAction,
  });

  final String configName;
  final String? customDownloadFileNameFormat;
  final String? customBulkDownloadFileNameFormat;
  final Set<Rating>? granularRatingFilters;
  final BooruConfigRatingFilter? ratingFilter;
  final String? imageDetaisQuality;
  final PostGestureConfig? postGestures;
  final String? defaultPreviewImageButtonAction;

  @override
  List<Object?> get props => [
        configName,
        customDownloadFileNameFormat,
        customBulkDownloadFileNameFormat,
        granularRatingFilters,
        ratingFilter,
        imageDetaisQuality,
        postGestures,
        defaultPreviewImageButtonAction,
      ];
}

extension CreateConfigDataX on CreateConfigData {
  BooruConfigData toBooruConfigDataFromInitialConfig({
    required BooruConfig config,
    required String login,
    required String apiKey,
    required bool hideDeleted,
  }) =>
      BooruConfigData(
        login: login,
        apiKey: apiKey,
        booruId: config.booruType.toBooruId(),
        booruIdHint: config.booruType.toBooruId(),
        name: configName,
        deletedItemBehavior: hideDeleted
            ? BooruConfigDeletedItemBehavior.hide.index
            : BooruConfigDeletedItemBehavior.show.index,
        ratingFilter: ratingFilter?.index ?? BooruConfigRatingFilter.none.index,
        url: config.url,
        customDownloadFileNameFormat: customDownloadFileNameFormat,
        customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
        imageDetaisQuality: imageDetaisQuality,
        granularRatingFilterString:
            granularRatingFilterToString(granularRatingFilters),
        postGestures: postGestures?.toJsonString(),
        defaultPreviewImageButtonAction: defaultPreviewImageButtonAction,
      );
}

const kDefaultPreviewImageButtonAction = {
  '',
  null,
  kToggleBookmarkAction,
  kDownloadAction,
  kViewArtistAction,
};

class CreateBooruConfigScaffold extends ConsumerStatefulWidget {
  const CreateBooruConfigScaffold({
    super.key,
    this.backgroundColor,
    required this.config,
    required this.tabsBuilder,
    required this.allowSubmit,
    required this.submit,
    required this.isNewConfig,
    this.authTab,
    this.postDetailsResolutionBuilder,
    this.hasDownloadTab = false,
    this.hasRatingFilter = false,
    this.miscOptionBuilder,
    this.postDetailsGestureActions = kDefaultGestureActions,
    this.postPreviewQuickActionButtonActions = kDefaultPreviewImageButtonAction,
    this.describePostDetailsAction,
    this.describePostPreviewQuickAction,
    this.useNewSubmitFlow = false,
    this.onSubmit,
  }) : assert(useNewSubmitFlow == true || onSubmit == null);

  final Color? backgroundColor;
  final BooruConfig config;
  final Map<String, Widget> Function(BuildContext context) tabsBuilder;
  final bool Function(CreateConfigData data) allowSubmit;
  final void Function(CreateConfigData data)? submit;

  final Widget? authTab;

  final Widget Function(BuildContext context)? postDetailsResolutionBuilder;

  final bool hasDownloadTab;
  final bool hasRatingFilter;

  final List<Widget> Function(BuildContext context)? miscOptionBuilder;

  final Set<String?> postDetailsGestureActions;
  final String Function(String? action)? describePostDetailsAction;

  final Set<String?> postPreviewQuickActionButtonActions;
  final String Function(String? action)? describePostPreviewQuickAction;
  final bool isNewConfig;

  //TODO: Temp
  final bool useNewSubmitFlow;
  final BooruConfigData Function(CreateConfigData data)? onSubmit;

  @override
  ConsumerState<CreateBooruConfigScaffold> createState() =>
      _CreateBooruConfigScaffoldState();
}

class _CreateBooruConfigScaffoldState
    extends ConsumerState<CreateBooruConfigScaffold> {
  late var configName = widget.config.name;
  late String? customDownloadFileNameFormat =
      widget.config.customDownloadFileNameFormat;
  late var customBulkDownloadFileNameFormat =
      widget.config.customBulkDownloadFileNameFormat;
  late var ratingFilter = widget.config.ratingFilter;
  late var granularRatingFilters = widget.config.granularRatingFilters;
  late var imageDetaisQuality = widget.config.imageDetaisQuality;
  late var postGestures =
      widget.config.postGestures ?? const PostGestureConfig.undefined();
  late var defaultPreviewImageButtonAction =
      widget.config.defaultPreviewImageButtonAction;

  @override
  Widget build(BuildContext context) {
    final tabMap = {
      if (widget.authTab != null) 'booru.authentication': widget.authTab!,
      if (widget.hasDownloadTab) 'booru.download': _buildDownloadTab(),
      ...widget.tabsBuilder(context),
      'booru.gestures': _buildGesturesTab(),
      'booru.misc': _buildMiscTab(),
    };

    final params = CreateConfigData(
      configName: configName,
      customDownloadFileNameFormat: customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
      granularRatingFilters: granularRatingFilters,
      ratingFilter: ratingFilter,
      imageDetaisQuality: imageDetaisQuality,
      postGestures: postGestures,
      defaultPreviewImageButtonAction: defaultPreviewImageButtonAction,
    );

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
                          if (widget.isNewConfig)
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
                                child: !widget.useNewSubmitFlow
                                    ? CreateBooruSubmitButton(
                                        onSubmit: widget.allowSubmit(params)
                                            ? () => widget.submit?.call(params)
                                            : null,
                                      )
                                    : CreateBooruSubmitButton(
                                        onSubmit: widget.onSubmit != null &&
                                                widget.allowSubmit(params)
                                            ? () {
                                                final data =
                                                    widget.onSubmit!(params);

                                                ref
                                                    .read(booruConfigProvider
                                                        .notifier)
                                                    .addOrUpdateUsingBooruConfigData(
                                                      config: widget.config,
                                                      newConfig: data,
                                                    );

                                                context.navigator.pop();
                                              }
                                            : null,
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

  Widget _buildDownloadTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomDownloadFileNameSection(
            config: widget.config,
            format: customDownloadFileNameFormat,
            onIndividualDownloadChanged: (value) =>
                setState(() => customDownloadFileNameFormat = value),
            onBulkDownloadChanged: (value) =>
                setState(() => customBulkDownloadFileNameFormat = value),
          ),
        ],
      ),
    );
  }

  Widget _buildGesturesTab() {
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
              value: postGestures.fullview?.swipeDown,
              onChanged: (value) {
                setState(() =>
                    postGestures = postGestures.withFulviewSwipeDown(value));
              },
              items: widget.postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(widget.describePostDetailsAction != null
                            ? widget.describePostDetailsAction!(value)
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
              value: postGestures.fullview?.doubleTap,
              onChanged: (value) {
                setState(() =>
                    postGestures = postGestures.withFulviewDoubleTap(value));
              },
              items: widget.postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(widget.describePostDetailsAction != null
                            ? widget.describePostDetailsAction!(value)
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
              value: postGestures.fullview?.longPress,
              onChanged: (value) {
                setState(() =>
                    postGestures = postGestures.withFulviewLongPress(value));
              },
              items: widget.postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(widget.describePostDetailsAction != null
                            ? widget.describePostDetailsAction!(value)
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
              value: postGestures.preview?.tap,
              onChanged: (value) {
                setState(
                    () => postGestures = postGestures.withPreviewTap(value));
              },
              items: widget.postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(widget.describePostDetailsAction != null
                            ? widget.describePostDetailsAction!(value)
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
              value: postGestures.preview?.longPress,
              onChanged: (value) {
                setState(() =>
                    postGestures = postGestures.withPreviewLongPress(value));
              },
              items: widget.postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(widget.describePostDetailsAction != null
                            ? widget.describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Override the default gestures for this profile, select "None" to keep the original behavior.',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.theme.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiscTab() {
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
              value: defaultPreviewImageButtonAction,
              onChanged: (value) {
                setState(() => defaultPreviewImageButtonAction = value);
              },
              items: widget.postPreviewQuickActionButtonActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                            widget.describePostPreviewQuickAction != null
                                ? widget.describePostPreviewQuickAction!(value)
                                : describeImagePreviewQuickAction(value)),
                      ))
                  .toList(),
            ),
          ),
          if (widget.hasRatingFilter) ...[
            CreateBooruRatingOptionsTile(
              config: widget.config,
              initialGranularRatingFilters: granularRatingFilters,
              value: ratingFilter,
              onChanged: (value) =>
                  value != null ? setState(() => ratingFilter = value) : null,
              onGranularRatingFiltersChanged: (value) =>
                  setState(() => granularRatingFilters = value),
            ),
          ],
          if (widget.postDetailsResolutionBuilder != null)
            widget.postDetailsResolutionBuilder!(context)
          else
            CreateBooruGeneralPostDetailsResolutionOptionTile(
              value: imageDetaisQuality,
              onChanged: (value) => setState(() => imageDetaisQuality = value),
            ),
          if (widget.miscOptionBuilder != null)
            ...widget.miscOptionBuilder!(context),
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
