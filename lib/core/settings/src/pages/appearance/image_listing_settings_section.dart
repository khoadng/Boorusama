// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../home/types.dart';
import '../../../../images/types.dart';
import '../../../../posts/listing/types.dart';
import '../../../../posts/post/types.dart';
import '../../generated/settings_index.g.dart';
import '../../providers/settings_notifier.dart';
import '../../providers/settings_provider.dart';
import '../../types/settings.dart';
import '../../types/utils.dart';
import '../../widgets/setting_anchor.dart';

class ImageListingSettingsSection extends ConsumerStatefulWidget {
  const ImageListingSettingsSection({
    required this.listing,
    required this.onUpdate,
    super.key,
    this.itemPadding,
    this.extraChildren = const [],
  });

  final ImageListingSettings listing;
  final void Function(ImageListingSettings) onUpdate;
  final EdgeInsetsGeometry? itemPadding;
  final List<Widget> extraChildren;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ImageListingSettingsSectionState();
}

class _ImageListingSettingsSectionState
    extends ConsumerState<ImageListingSettingsSection> {
  late var settings = widget.listing;

  late final ValueNotifier<double> _spacingSliderValue = ValueNotifier(0);
  late final ValueNotifier<double> _borderRadiusSliderValue = ValueNotifier(0);
  late final ValueNotifier<double> _paddingSliderValue = ValueNotifier(0);
  late final ValueNotifier<double> _aspectRatioSliderValue = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _spacingSliderValue.value = settings.imageGridSpacing;
    _borderRadiusSliderValue.value = settings.imageBorderRadius;
    _paddingSliderValue.value = settings.imageGridPadding;
    _aspectRatioSliderValue.value = settings.imageGridAspectRatio;
  }

  @override
  void didUpdateWidget(covariant ImageListingSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.listing != widget.listing) {
      setState(() {
        settings = widget.listing;
      });
    }
  }

  void _onUpdate(ImageListingSettings newSettings) {
    widget.onUpdate(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingAnchor(
          id: SettingsIndex.listing.gridSize.id,
          child: KurumiSettingsTile(
            title: Text(
              SettingsIndex.listing.gridSize.title(context),
            ),
            selectedOption: settings.gridSize,
            items: GridSize.sortedValues,
            onChanged: (value) => _onUpdate(settings.copyWith(gridSize: value)),
            optionBuilder: (value) => Text(value.localize(context)),
          ),
        ),
        SettingAnchor(
          id: SettingsIndex.listing.list.id,
          child: KurumiSettingsTile(
            title: Text(
              SettingsIndex.listing.list.title(context),
            ),
            selectedOption: settings.imageListType,
            items: ImageListType.values,
            onChanged: (value) =>
                _onUpdate(settings.copyWith(imageListType: value)),
            optionBuilder: (value) => Text(value.localize(context)),
          ),
        ),
        SettingAnchor(
          id: SettingsIndex.listing.imageQuality.id,
          child: KurumiSettingsTile(
            title: Text(
              SettingsIndex.listing.imageQuality.title(
                context,
              ),
            ),
            subtitle: settings.imageQuality == ImageQuality.highest
                ? Text(
                    context
                        .t
                        .settings
                        .image_grid
                        .image_quality
                        .high_quality_notice,
                    style: TextStyle(
                      color: Kurumi.themeOf(context).colorScheme.hintColor,
                    ),
                  )
                : null,
            selectedOption: settings.imageQuality,
            items: ImageQuality.nonOriginalValues,
            onChanged: (value) =>
                _onUpdate(settings.copyWith(imageQuality: value)),
            optionBuilder: (value) => Text(value.localize(context)),
          ),
        ),
        SettingAnchor(
          id: SettingsIndex.listing.layout.id,
          child: KurumiSettingsTile(
            title: Text(
              SettingsIndex.listing.layout.title(context),
            ),
            selectedOption: settings.pageMode,
            subtitle: settings.pageMode == PageMode.infinite
                ? Text(context.t.settings.infinite_scroll_warning)
                : null,
            items: const [...PageMode.values],
            onChanged: (value) => _onUpdate(settings.copyWith(pageMode: value)),
            optionBuilder: (value) => Text(value.localize(context)),
          ),
        ),
        if (settings.pageMode == PageMode.paginated)
          SettingAnchor(
            id: SettingsIndex.listing.pageIndicator.id,
            child: KurumiSettingsTile(
              title: Text(
                SettingsIndex.listing.pageIndicator.title(context),
              ),
              selectedOption: settings.pageIndicatorPosition,
              items: const [...PageIndicatorPosition.values],
              onChanged: (value) =>
                  _onUpdate(settings.copyWith(pageIndicatorPosition: value)),
              optionBuilder: (value) => Text(value.localize(context)),
            ),
          ),
        SettingAnchor(
          id: SettingsIndex.listing.postsPerPage.id,
          child: KurumiSettingsTile(
            title: Text(
              SettingsIndex.listing.postsPerPage.title(
                context,
              ),
            ),
            subtitle: Text(
              context.t.settings.performance.posts_per_page_explain,
              style: TextStyle(
                color: Kurumi.themeOf(context).colorScheme.hintColor,
              ),
            ),
            selectedOption: settings.postsPerPage,
            items: getPostsPerPagePossibleValue(),
            onChanged: (newValue) {
              _onUpdate(
                settings.copyWith(
                  postsPerPage: newValue,
                ),
              );
            },
            optionBuilder: (value) => Text(
              value.toString(),
            ),
          ),
        ),
        SettingAnchor(
          id: SettingsIndex.listing.showScores.id,
          child: KurumiSwitchListTile(
            title: Text(
              SettingsIndex.listing.showScores.title(
                context,
              ),
            ),
            value: settings.showScoresInGrid,
            onChanged: (value) =>
                _onUpdate(settings.copyWith(showScoresInGrid: value)),
          ),
        ),
        SettingAnchor(
          id: SettingsIndex.listing.showConfigHeader.id,
          child: KurumiSwitchListTile(
            title: Text(
              SettingsIndex.listing.showConfigHeader.title(context),
            ),
            value: settings.showPostListConfigHeader,
            onChanged: (value) => _onUpdate(
              settings.copyWith(
                showPostListConfigHeader: value,
              ),
            ),
          ),
        ),
        SettingAnchor(
          id: SettingsIndex.listing.blurExplicitMedia.id,
          child: KurumiSwitchListTile(
            title: Text(
              SettingsIndex.listing.blurExplicitMedia.title(context),
            ),
            value: settings.mediaBlurCondition.blurExplicitMedia,
            onChanged: (value) => _onUpdate(
              settings.copyWith(
                mediaBlurCondition: value
                    ? MediaBlurCondition.explicitOnly
                    : MediaBlurCondition.none,
              ),
            ),
          ),
        ),
        SettingAnchor(
          id: SettingsIndex.listing.autoPlayGif.id,
          child: KurumiSwitchListTile(
            title: Text(
              SettingsIndex.listing.autoPlayGif.title(
                context,
              ),
            ),
            value:
                settings.animatedPostsDefaultState ==
                AnimatedPostsDefaultState.autoplay,
            onChanged: (value) => _onUpdate(
              settings.copyWith(
                animatedPostsDefaultState: value
                    ? AnimatedPostsDefaultState.autoplay
                    : AnimatedPostsDefaultState.static,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        _buildSpacingSlider(settings),
        const SizedBox(height: 10),
        _buildBorderRadiusSlider(settings),
        const SizedBox(height: 10),
        _buildPaddingSlider(settings),
        const SizedBox(height: 10),
        _buildAspectRatioSlider(settings),
        const SizedBox(height: 10),
        ...widget.extraChildren,
      ],
    );
  }

  Widget _buildBorderRadiusSlider(ImageListingSettings settings) {
    return ValueListenableBuilder(
      valueListenable: _borderRadiusSliderValue,
      builder: (context, value, child) {
        return SettingAnchor(
          id: SettingsIndex.listing.cornerRadius.id,
          child: KurumiSettingsSliderTile(
            title: SettingsIndex.listing.cornerRadius.title(
              context,
            ),
            divisions: 20,
            max: 20,
            value: value,
            onChangeEnd: (value) =>
                _onUpdate(settings.copyWith(imageBorderRadius: value)),
            onChanged: (value) => _borderRadiusSliderValue.value = value,
            padding: EdgeInsets.zero,
          ),
        );
      },
    );
  }

  Widget _buildSpacingSlider(ImageListingSettings settings) {
    return ValueListenableBuilder(
      valueListenable: _spacingSliderValue,
      builder: (context, value, child) {
        return SettingAnchor(
          id: SettingsIndex.listing.spacing.id,
          child: KurumiSettingsSliderTile(
            title: SettingsIndex.listing.spacing.title(
              context,
            ),
            divisions: 10,
            max: 10,
            value: value,
            onChangeEnd: (value) =>
                _onUpdate(settings.copyWith(imageGridSpacing: value)),
            onChanged: (value) => _spacingSliderValue.value = value,
            padding: EdgeInsets.zero,
          ),
        );
      },
    );
  }

  Widget _buildPaddingSlider(ImageListingSettings settings) {
    return ValueListenableBuilder(
      valueListenable: _paddingSliderValue,
      builder: (context, value, child) {
        return SettingAnchor(
          id: SettingsIndex.listing.padding.id,
          child: KurumiSettingsSliderTile(
            title: SettingsIndex.listing.padding.title(
              context,
            ),
            divisions: 8,
            max: 32,
            value: value,
            onChangeEnd: (value) =>
                _onUpdate(settings.copyWith(imageGridPadding: value)),
            onChanged: (value) => _paddingSliderValue.value = value,
            padding: EdgeInsets.zero,
          ),
        );
      },
    );
  }

  Widget _buildAspectRatioSlider(ImageListingSettings settings) {
    return ValueListenableBuilder(
      valueListenable: _aspectRatioSliderValue,
      builder: (context, value, child) {
        return SettingAnchor(
          id: SettingsIndex.listing.aspectRatio.id,
          child: KurumiSettingsSliderTile(
            title: SettingsIndex.listing.aspectRatio.title(
              context,
            ),
            divisions: 10,
            max: 1.5,
            min: 0.5,
            value: value,
            onChangeEnd: (value) =>
                _onUpdate(settings.copyWith(imageGridAspectRatio: value)),
            onChanged: (value) => _aspectRatioSliderValue.value = value,
            padding: EdgeInsets.zero,
          ),
        );
      },
    );
  }
}

class LayoutSection extends ConsumerWidget {
  const LayoutSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.watch(settingsNotifierProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KurumiSettingsHeader(
          label: context.t.settings.appearance.booru_config,
        ),
        SettingAnchor(
          id: SettingsIndex.listing.profilePlacement.id,
          child: KurumiSettingsTile(
            title: Text(
              SettingsIndex.listing.profilePlacement.title(context),
            ),
            selectedOption: settings.booruConfigSelectorPosition,
            items: const [...BooruConfigSelectorPosition.values],
            onChanged: (value) => notifier.updateSettings(
              settings.copyWith(booruConfigSelectorPosition: value),
            ),
            optionBuilder: (value) => Text(value.localize(context)),
          ),
        ),
        SettingAnchor(
          id: SettingsIndex.listing.profileLabel.id,
          child: KurumiSettingsTile(
            title: Text(
              SettingsIndex.listing.profileLabel.title(
                context,
              ),
            ),
            selectedOption: settings.booruConfigLabelVisibility,
            items: const [...BooruConfigLabelVisibility.values],
            onChanged: (value) => notifier.updateSettings(
              settings.copyWith(booruConfigLabelVisibility: value),
            ),
            optionBuilder: (value) => Text(value.localize(context)),
          ),
        ),
      ],
    );
  }
}
