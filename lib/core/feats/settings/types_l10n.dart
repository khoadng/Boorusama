// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';
import 'types.dart';

extension PageModeTranslated on PageMode {
  String localize() => switch (this) {
        PageMode.infinite => 'settings.result_layout.infinite_scroll',
        PageMode.paginated => 'settings.result_layout.pagination'
      };
}

extension ThemeModeTranslated on AppThemeMode {
  String localize() => switch (this) {
        AppThemeMode.dark => 'settings.theme.dark',
        AppThemeMode.system => 'System',
        AppThemeMode.amoledDark => 'settings.theme.amoled_dark',
        AppThemeMode.light => 'settings.theme.light',
      };
}

extension ImageListTypeTranslated on ImageListType {
  String localize() => switch (this) {
        ImageListType.standard => 'settings.image_list.standard',
        ImageListType.masonry => 'settings.image_list.masonry'
      };
}

extension ImageGridSizeTranslated on GridSize {
  String localize() => switch (this) {
        GridSize.large => 'settings.image_grid.grid_size.large',
        GridSize.small => 'settings.image_grid.grid_size.small',
        GridSize.normal => 'settings.image_grid.grid_size.medium'
      };
}

extension ImageQualityTranslated on ImageQuality {
  String localize() => switch (this) {
        ImageQuality.highest => 'settings.image_grid.image_quality.highest',
        ImageQuality.high => 'settings.image_grid.image_quality.high',
        ImageQuality.low => 'settings.image_grid.image_quality.low',
        ImageQuality.original => 'settings.image_grid.image_quality.original',
        ImageQuality.automatic => 'settings.image_grid.image_quality.automatic'
      };
}

extension PostDetailsOverlayInitialStateTranslated
    on PostDetailsOverlayInitialState {
  String localize() => switch (this) {
        PostDetailsOverlayInitialState.show =>
          'settings.image_details.ui_overlay.show',
        PostDetailsOverlayInitialState.hide =>
          'settings.image_details.ui_overlay.hide',
      };
}

extension PageIndicatorPositionTranslated on PageIndicatorPosition {
  String localize() => switch (this) {
        PageIndicatorPosition.top => 'settings.page_indicator.top',
        PageIndicatorPosition.bottom => 'settings.page_indicator.bottom',
        PageIndicatorPosition.both => 'settings.page_indicator.both',
      };
}

extension BooruConfigSelectorPositionTranslated on BooruConfigSelectorPosition {
  String localize() => switch (this) {
        BooruConfigSelectorPosition.side => 'Side',
        BooruConfigSelectorPosition.bottom => 'Bottom',
      };
}

extension BooruConfigLabelVisibilityTranslated on BooruConfigLabelVisibility {
  String localize() => switch (this) {
        BooruConfigLabelVisibility.always => 'On',
        BooruConfigLabelVisibility.never => 'Off',
      };
}
