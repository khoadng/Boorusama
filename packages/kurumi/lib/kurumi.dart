library;

// Public API is intentionally organized around the design language:
// accessibility behavior, reusable visual primitives, theme foundations, and
// responsive/platform primitives. Feature workflows and app policy stay in
// the application package.

export 'src/kurumi.dart';

export 'package:anchor_ui/anchor_ui.dart' show AnchorController, Placement;

export 'src/accessibility/behavior.dart';
export 'src/accessibility/scrolling.dart';
export 'src/components/adaptive_button_row.dart';
export 'src/components/adaptive_sheet.dart'
    hide
        kurumiShowAdaptiveSheet,
        kurumiShowAdaptiveBottomSheet,
        kurumiShowAppModalBarBottomSheet,
        kurumiShowSideSheetFromLeft,
        kurumiShowSideSheetFromRight;
export 'src/components/action_animation_overlay.dart';
export 'src/components/animated_cross_fade.dart';
export 'src/components/anchor.dart';
export 'src/components/bottom_sheet.dart' hide showKurumiModalBottomSheet;
export 'src/components/bottom_sheet_actions.dart';
export 'src/components/bottom_sheet_header.dart';
export 'src/components/button.dart';
export 'src/components/chip.dart';
export 'src/components/circular_icon_button.dart';
export 'src/components/compact_chip.dart';
export 'src/components/context_menu.dart';
export 'src/components/custom_context_menu_overlay.dart';
export 'src/components/desktop_window.dart';
export 'src/components/dialog.dart';
export 'src/components/dialog_content.dart';
export 'src/components/dismissible_info_container.dart';
export 'src/components/drag_line.dart';
export 'src/components/dotted_border.dart';
export 'src/components/grayed_out.dart';
export 'src/components/info_container.dart';
export 'src/components/info_circle.dart';
export 'src/components/interactive_viewer.dart';
export 'src/components/linear_progress_indicator.dart';
export 'src/components/like_button.dart';
export 'src/components/no_data.dart';
export 'src/components/hero.dart' hide kKurumiEnableHeroTransition;
export 'src/components/hover_aware_container.dart';
export 'src/components/image_placeholder.dart';
export 'src/components/image_error_placeholder.dart';
export 'src/components/refresh_indicator.dart';
export 'src/components/media_query.dart';
export 'src/components/material_controls.dart';
export 'src/components/material_chips.dart';
export 'src/components/navigation_tile.dart';
export 'src/components/option_dropdown.dart';
export 'src/components/option_searchable_sheet.dart';
export 'src/components/page_indicator.dart';
export 'src/components/popup_menu.dart';
export 'src/components/pulse_indicator.dart';
export 'src/components/scroll_button.dart';
export 'src/components/scroll_visibility.dart';
export 'src/components/route_transition.dart'
    hide
        kurumiParallaxSlideInTransitionBuilder,
        kurumiLeftToRightTransitionBuilder,
        kurumiFadeTransitionBuilder;
export 'src/components/search_bar.dart';
export 'src/components/selectable_item.dart';
export 'src/components/selectable_chip.dart';
export 'src/components/selection_tile.dart';
export 'src/components/segmented_button.dart' hide kurumiComputeSegmentOffset;
export 'src/components/settings_card.dart';
export 'src/components/settings_header.dart';
export 'src/components/settings_radio_card.dart';
export 'src/components/settings_slider_tile.dart';
export 'src/components/settings_tile.dart';
export 'src/components/settings_navigation_tile.dart';
export 'src/components/side_menu_tile.dart';
export 'src/components/slider.dart';
export 'src/components/shadow_gradient_overlay.dart';
export 'src/components/sliver_divider.dart';
export 'src/components/square_chip.dart';
export 'src/components/status_box.dart';
export 'src/components/switch_list_tile.dart';
export 'src/components/text_field.dart';
export 'src/components/text_form_field.dart';
export 'src/components/toast.dart'
    hide kurumiShowSuccessToast, kurumiShowErrorToast, kurumiShowSimpleSnackBar;
export 'src/components/tooltip.dart';
export 'src/theme/theme.dart';
export 'src/theme/theme_data.dart';
export 'src/theme/theme_mode.dart';
export 'src/theme/extended_color_scheme.dart';
export 'src/theme/color_tokens.dart';
export 'src/theme/color_schemes.dart';
export 'src/theme/color_harmonizer.dart';
export 'src/theme/dynamic_color.dart';
export 'src/theme/durations.dart';
export 'src/theme/extensions.dart';
export 'src/theme/grayscale_shades.dart';
export 'src/theme/material_theme.dart';
export 'src/theme/preset_color_schemes.dart';
export 'src/theme/semantic_tokens.dart';
export 'src/theme/slider_shapes.dart';
export 'src/foundation/preferred_layout.dart' hide kurumiPreferredLayout;
export 'src/foundation/platform.dart'
    hide kurumiIsMobilePlatform, kurumiIsDesktopPlatform;
export 'src/foundation/screen.dart';
