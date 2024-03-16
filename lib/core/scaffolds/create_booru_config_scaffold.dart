// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/booru_config.dart';
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
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

typedef CreateConfigData = ({
  String configName,
  String? customDownloadFileNameFormat,
  String? customBulkDownloadFileNameFormat,
  Set<Rating>? granularRatingFilters,
  BooruConfigRatingFilter? ratingFilter,
  String? imageDetaisQuality,
  PostGestureConfig? postGestures,
  String? defaultPreviewImageButtonAction,
});

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
    this.authTabBuilder,
    this.postDetailsResolutionBuilder,
    this.hasDownloadTab = false,
    this.hasRatingFilter = false,
    this.miscOptionBuilder,
    this.postDetailsGestureActions = kDefaultGestureActions,
    this.postPreviewQuickActionButtonActions = kDefaultPreviewImageButtonAction,
    this.describePostDetailsAction,
    this.describePostPreviewQuickAction,
  });

  final Color? backgroundColor;
  final BooruConfig config;
  final Map<String, Widget> Function(BuildContext context) tabsBuilder;
  final bool Function(CreateConfigData data) allowSubmit;
  final void Function(CreateConfigData data) submit;

  final Widget Function(BuildContext context)? authTabBuilder;

  final Widget Function(BuildContext context)? postDetailsResolutionBuilder;

  final bool hasDownloadTab;
  final bool hasRatingFilter;

  final List<Widget> Function(BuildContext context)? miscOptionBuilder;

  final Set<String?> postDetailsGestureActions;
  final String Function(String? action)? describePostDetailsAction;

  final Set<String?> postPreviewQuickActionButtonActions;
  final String Function(String? action)? describePostPreviewQuickAction;
  final bool isNewConfig;

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
      if (widget.authTabBuilder != null)
        'Authentication': widget.authTabBuilder!(context),
      if (widget.hasDownloadTab) 'Download': _buildDownloadTab(),
      ...widget.tabsBuilder(context),
      'Gestures': _buildGesturesTab(),
      'Misc': _buildMiscTab(),
    };

    final params = (
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
                                child: CreateBooruSubmitButton(
                                  onSubmit: widget.allowSubmit(params)
                                      ? () => widget.submit(params)
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
            title: const Text('Swipe down'),
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
            title: const Text('Double tap'),
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
            title: const Text('Long press'),
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
            title: const Text('Tap'),
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
            title: const Text('Long press'),
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
