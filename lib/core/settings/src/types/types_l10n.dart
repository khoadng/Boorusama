// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../theme.dart';
import 'types.dart';

extension PageModeTranslated on PageMode {
  String localize(BuildContext context) => switch (this) {
    PageMode.infinite => context.t.settings.result_layout.infinite_scroll,
    PageMode.paginated => context.t.settings.result_layout.pagination,
  };
}

extension ThemeModeTranslated on AppThemeMode {
  String localize(BuildContext context) => switch (this) {
    AppThemeMode.dark => context.t.settings.theme.dark,
    AppThemeMode.system => 'System'.hc,
    AppThemeMode.amoledDark => context.t.settings.theme.amoled_dark,
    AppThemeMode.light => context.t.settings.theme.light,
  };
}

extension ImageListTypeTranslated on ImageListType {
  String localize(BuildContext context) => switch (this) {
    ImageListType.standard => context.t.settings.image_list.standard,
    ImageListType.masonry => context.t.settings.image_list.masonry,
    ImageListType.classic => 'Classic'.hc,
  };
}

extension ImageGridSizeTranslated on GridSize {
  String localize(BuildContext context) => switch (this) {
    GridSize.large => context.t.settings.image_grid.grid_size.large,
    GridSize.small => context.t.settings.image_grid.grid_size.small,
    GridSize.normal => context.t.settings.image_grid.grid_size.medium,
  };
}

extension ImageQualityTranslated on ImageQuality {
  String localize(BuildContext context) => switch (this) {
    ImageQuality.highest => context.t.settings.image_grid.image_quality.highest,
    ImageQuality.high => context.t.settings.image_grid.image_quality.high,
    ImageQuality.low => context.t.settings.image_grid.image_quality.low,
    ImageQuality.original =>
      context.t.settings.image_grid.image_quality.original,
    ImageQuality.automatic =>
      context.t.settings.image_grid.image_quality.automatic,
  };
}

extension PostDetailsOverlayInitialStateTranslated
    on PostDetailsOverlayInitialState {
  String localize(BuildContext context) => switch (this) {
    PostDetailsOverlayInitialState.show =>
      context.t.settings.image_details.ui_overlay.show,
    PostDetailsOverlayInitialState.hide =>
      context.t.settings.image_details.ui_overlay.hide,
  };
}

extension PageIndicatorPositionTranslated on PageIndicatorPosition {
  String localize(BuildContext context) => switch (this) {
    PageIndicatorPosition.top => context.t.settings.page_indicator.top,
    PageIndicatorPosition.bottom => context.t.settings.page_indicator.bottom,
    PageIndicatorPosition.both => context.t.settings.page_indicator.both,
  };
}

extension BooruConfigSelectorPositionTranslated on BooruConfigSelectorPosition {
  String localize(BuildContext context) => switch (this) {
    BooruConfigSelectorPosition.side => 'Side'.hc,
    BooruConfigSelectorPosition.bottom => 'Bottom'.hc,
  };
}

extension BooruConfigLabelVisibilityTranslated on BooruConfigLabelVisibility {
  String localize(BuildContext context) => switch (this) {
    BooruConfigLabelVisibility.always => 'On'.hc,
    BooruConfigLabelVisibility.never => 'Off'.hc,
  };
}

extension SlideshowDirectionTranslated on SlideshowDirection {
  String localize(BuildContext context) => switch (this) {
    SlideshowDirection.forward =>
      context.t.settings.image_viewer.slideshow_modes.forward,
    SlideshowDirection.backward =>
      context.t.settings.image_viewer.slideshow_modes.backward,
    SlideshowDirection.random =>
      context.t.settings.image_viewer.slideshow_modes.random,
  };
}

extension VideoPlayerEngineTranslated on VideoPlayerEngine {
  String localize(BuildContext context) => switch (this) {
    VideoPlayerEngine.auto => 'Default',
    VideoPlayerEngine.videoPlayerPlugin => 'video_player',
    VideoPlayerEngine.mdk => 'mdk',
  };
}

extension SearchBarPositionTranslated on SearchBarPosition {
  String localize(BuildContext context) => switch (this) {
    SearchBarPosition.top => 'Top'.hc,
    SearchBarPosition.bottom => 'Bottom'.hc,
  };
}
