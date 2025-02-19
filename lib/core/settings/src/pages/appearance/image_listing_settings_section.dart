// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../theme/theme.dart';
import '../../../widgets.dart';
import '../../providers/settings_notifier.dart';
import '../../providers/settings_provider.dart';
import '../../types/settings.dart';
import '../../types/types.dart';
import '../../types/types_l10n.dart';
import '../../types/utils.dart';
import '../../widgets/settings_header.dart';
import '../../widgets/settings_slider_tile.dart';

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
        SettingsTile(
          title: const Text('settings.image_grid.grid_size.grid_size').tr(),
          selectedOption: settings.gridSize,
          items: GridSize.values,
          onChanged: (value) => _onUpdate(settings.copyWith(gridSize: value)),
          optionBuilder: (value) => Text(value.localize().tr()),
        ),
        SettingsTile(
          title: const Text('settings.image_list.image_list').tr(),
          selectedOption: settings.imageListType,
          items: ImageListType.values,
          onChanged: (value) =>
              _onUpdate(settings.copyWith(imageListType: value)),
          optionBuilder: (value) => Text(value.localize()).tr(),
        ),
        SettingsTile(
          title: const Text(
            'settings.image_grid.image_quality.image_quality',
          ).tr(),
          subtitle: settings.imageQuality == ImageQuality.highest
              ? Text(
                  'settings.image_grid.image_quality.high_quality_notice',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.hintColor,
                  ),
                ).tr()
              : null,
          selectedOption: settings.imageQuality,
          items: [...ImageQuality.values]..remove(ImageQuality.original),
          onChanged: (value) =>
              _onUpdate(settings.copyWith(imageQuality: value)),
          optionBuilder: (value) => Text(value.localize()).tr(),
        ),
        SettingsTile(
          title: const Text('settings.result_layout.result_layout').tr(),
          selectedOption: settings.pageMode,
          subtitle: settings.pageMode == PageMode.infinite
              ? const Text('settings.infinite_scroll_warning').tr()
              : null,
          items: const [...PageMode.values],
          onChanged: (value) => _onUpdate(settings.copyWith(pageMode: value)),
          optionBuilder: (value) => Text(value.localize()).tr(),
        ),
        if (settings.pageMode == PageMode.paginated)
          SettingsTile(
            title: const Text('settings.page_indicator.page_indicator').tr(),
            selectedOption: settings.pageIndicatorPosition,
            items: const [...PageIndicatorPosition.values],
            onChanged: (value) =>
                _onUpdate(settings.copyWith(pageIndicatorPosition: value)),
            optionBuilder: (value) => Text(value.localize()).tr(),
          ),
        SettingsTile(
          title: const Text('settings.performance.posts_per_page').tr(),
          subtitle: Text(
            'settings.performance.posts_per_page_explain',
            style: TextStyle(
              color: Theme.of(context).colorScheme.hintColor,
            ),
          ).tr(),
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
        SwitchListTile(
          title: const Text('settings.appearance.show_scores').tr(),
          value: settings.showScoresInGrid,
          onChanged: (value) =>
              _onUpdate(settings.copyWith(showScoresInGrid: value)),
        ),
        SwitchListTile(
          title: const Text('settings.appearance.show_post_list_config_header')
              .tr(),
          value: settings.showPostListConfigHeader,
          onChanged: (value) => _onUpdate(
            settings.copyWith(
              showPostListConfigHeader: value,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Blur explicit content').tr(),
          value: settings.blurExplicitMedia,
          onChanged: (value) => _onUpdate(
            settings.copyWith(
              mediaBlurCondition: value
                  ? MediaBlurCondition.explicitOnly
                  : MediaBlurCondition.none,
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
        const Divider(thickness: 1),
        const LayoutSection(),
        ...widget.extraChildren,
      ],
    );
  }

  Widget _buildBorderRadiusSlider(ImageListingSettings settings) {
    return ValueListenableBuilder(
      valueListenable: _borderRadiusSliderValue,
      builder: (context, value, child) {
        return SettingsSliderTile(
          title: 'settings.image_grid.corner_radius',
          divisions: 20,
          max: 20,
          value: value,
          onChangeEnd: (value) =>
              _onUpdate(settings.copyWith(imageBorderRadius: value)),
          onChanged: (value) => _borderRadiusSliderValue.value = value,
          padding: EdgeInsets.zero,
        );
      },
    );
  }

  Widget _buildSpacingSlider(ImageListingSettings settings) {
    return ValueListenableBuilder(
      valueListenable: _spacingSliderValue,
      builder: (context, value, child) {
        return SettingsSliderTile(
          title: 'settings.image_grid.spacing',
          divisions: 10,
          max: 10,
          value: value,
          onChangeEnd: (value) =>
              _onUpdate(settings.copyWith(imageGridSpacing: value)),
          onChanged: (value) => _spacingSliderValue.value = value,
          padding: EdgeInsets.zero,
        );
      },
    );
  }

  Widget _buildPaddingSlider(ImageListingSettings settings) {
    return ValueListenableBuilder(
      valueListenable: _paddingSliderValue,
      builder: (context, value, child) {
        return SettingsSliderTile(
          title: 'settings.image_grid.padding',
          divisions: 8,
          max: 32,
          value: value,
          onChangeEnd: (value) =>
              _onUpdate(settings.copyWith(imageGridPadding: value)),
          onChanged: (value) => _paddingSliderValue.value = value,
          padding: EdgeInsets.zero,
        );
      },
    );
  }

  Widget _buildAspectRatioSlider(ImageListingSettings settings) {
    return ValueListenableBuilder(
      valueListenable: _aspectRatioSliderValue,
      builder: (context, value, child) {
        return SettingsSliderTile(
          title: 'settings.image_grid.aspect_ratio',
          divisions: 10,
          max: 1.5,
          min: 0.5,
          value: value,
          onChangeEnd: (value) =>
              _onUpdate(settings.copyWith(imageGridAspectRatio: value)),
          onChanged: (value) => _aspectRatioSliderValue.value = value,
          padding: EdgeInsets.zero,
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
        SettingsHeader(label: 'settings.appearance.booru_config'.tr()),
        SettingsTile(
          title: const Text('settings.appearance.booru_config_placement').tr(),
          selectedOption: settings.booruConfigSelectorPosition,
          items: const [...BooruConfigSelectorPosition.values],
          onChanged: (value) => notifier.updateSettings(
            settings.copyWith(booruConfigSelectorPosition: value),
          ),
          optionBuilder: (value) => Text(value.localize()),
        ),
        SettingsTile(
          title: const Text('Label').tr(),
          selectedOption: settings.booruConfigLabelVisibility,
          items: const [...BooruConfigLabelVisibility.values],
          onChanged: (value) => notifier.updateSettings(
            settings.copyWith(booruConfigLabelVisibility: value),
          ),
          optionBuilder: (value) => Text(value.localize()),
        ),
      ],
    );
  }
}
