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
    AppThemeMode.system => context.t.settings.theme.system,
    AppThemeMode.amoledDark => context.t.settings.theme.amoled_dark,
    AppThemeMode.light => context.t.settings.theme.light,
  };
}

extension ImageListTypeTranslated on ImageListType {
  String localize(BuildContext context) => switch (this) {
    ImageListType.standard => context.t.settings.image_list.standard,
    ImageListType.masonry => context.t.settings.image_list.masonry,
    ImageListType.classic => context.t.settings.image_list.classic,
  };
}

extension ImageGridSizeTranslated on GridSize {
  String localize(BuildContext context) => switch (this) {
    GridSize.micro => context.t.settings.image_grid.grid_size.micro,
    GridSize.tiny => context.t.settings.image_grid.grid_size.tiny,
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
    BooruConfigSelectorPosition.side =>
      context.t.settings.appearance.booru_config_placement_options.side,
    BooruConfigSelectorPosition.bottom =>
      context.t.settings.appearance.booru_config_placement_options.bottom,
  };
}

extension BooruConfigLabelVisibilityTranslated on BooruConfigLabelVisibility {
  String localize(BuildContext context) => switch (this) {
    BooruConfigLabelVisibility.always =>
      context.t.settings.appearance.booru_config_label_options.always,
    BooruConfigLabelVisibility.never =>
      context.t.settings.appearance.booru_config_label_options.never,
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


extension SearchBarPositionTranslated on SearchBarPosition {
  String localize(BuildContext context) => switch (this) {
    SearchBarPosition.top => context.t.settings.search.search_bar.position.top,
    SearchBarPosition.bottom =>
      context.t.settings.search.search_bar.position.bottom,
  };
}

extension HapticFeedbackLevelTranslated on HapticFeedbackLevel {
  String localize(BuildContext context) => switch (this) {
    HapticFeedbackLevel.none =>
      context
          .t
          .settings
          .accessibility
          .haptic_feedback
          .haptic_feedback_level
          .none,
    HapticFeedbackLevel.reduced =>
      context
          .t
          .settings
          .accessibility
          .haptic_feedback
          .haptic_feedback_level
          .subtle,
    HapticFeedbackLevel.balanced =>
      context
          .t
          .settings
          .accessibility
          .haptic_feedback
          .haptic_feedback_level
          .standard,
    HapticFeedbackLevel.full =>
      context
          .t
          .settings
          .accessibility
          .haptic_feedback
          .haptic_feedback_level
          .playful,
  };
}
