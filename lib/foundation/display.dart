// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'platform.dart';

const _kRawPreferredLayout = String.fromEnvironment('PREFERRED_LAYOUT');

final kPreferredLayout = switch (_kRawPreferredLayout) {
  'mobile' => PreferredLayout.mobile,
  'desktop' => PreferredLayout.desktop,
  _ => PreferredLayout.platform,
};

enum ScreenSize {
  small,
  medium,
  large,
  veryLarge,
}

enum PreferredLayout {
  platform,
  mobile,
  desktop,
}

extension PreferredLayoutX on PreferredLayout {
  bool get isMobile =>
      this == PreferredLayout.mobile ||
      (this == PreferredLayout.platform && isMobilePlatform());
  bool get isDesktop =>
      this == PreferredLayout.desktop ||
      (this == PreferredLayout.platform && isDesktopPlatform());
}

ScreenSize screenWidthToDisplaySize(double width) => switch (width) {
      <= 600 => ScreenSize.small,
      <= 1100 => ScreenSize.medium,
      <= 1500 => ScreenSize.large,
      _ => ScreenSize.veryLarge,
    };

int displaySizeToGridCountWeight(ScreenSize size) => switch (size) {
      ScreenSize.small => 1,
      ScreenSize.medium => 2,
      ScreenSize.large => 3,
      ScreenSize.veryLarge => 4,
    };

int calculateGridCount(double width, GridSize size) {
  final displaySize = screenWidthToDisplaySize(width);
  final weight = displaySizeToGridCountWeight(displaySize);

  final count = switch (size) {
    GridSize.small => 2.5 * weight,
    GridSize.normal => 1.5 * weight,
    GridSize.large => 1 * weight,
  };

  return count.round();
}

class Screen {
  const Screen._(this.context);

  factory Screen.of(BuildContext context) => Screen._(context);

  final BuildContext context;

  Size get _size => MediaQuery.sizeOf(context);

  ScreenSize get size => screenWidthToDisplaySize(_size.width);

  ScreenSize nextBreakpoint() => switch (size) {
        ScreenSize.small => ScreenSize.medium,
        ScreenSize.medium => ScreenSize.large,
        ScreenSize.large => ScreenSize.veryLarge,
        ScreenSize.veryLarge => ScreenSize.veryLarge
      };
}

extension ScreenSizeX on ScreenSize {
  bool get isLarge => this != ScreenSize.small;
}

extension DisplayX on BuildContext {
  Screen get screen => Screen.of(this);
  Orientation get orientation => MediaQuery.orientationOf(this);
}

extension OrientationX on Orientation {
  bool get isLandscape => this == Orientation.landscape;
  bool get isPortrait => this == Orientation.portrait;
}

Future<T?> showAdaptiveSheet<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
  bool expand = false,
  double? width,
  Color? backgroundColor,
  RouteSettings? settings,
}) {
  if (Screen.of(context).size == ScreenSize.small) {
    return showMaterialModalBottomSheet<T>(
      settings: settings,
      context: context,
      backgroundColor: backgroundColor,
      duration: AppDurations.bottomSheet,
      expand: expand,
      builder: builder,
    );
  } else {
    return showSideSheetFromRight<T>(
      settings: settings,
      width: width ?? 320,
      body: builder(context),
      context: context,
    );
  }
}

Future<T?> showAdaptiveBottomSheet<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
  bool expand = false,
  double? height,
  Color? backgroundColor,
  RouteSettings? settings,
}) {
  return Screen.of(context).size != ScreenSize.small
      ? showDialog<T>(
          context: context,
          routeSettings: settings,
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 24,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 400,
                maxWidth: 500,
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              child: builder(context),
            ),
          ),
        )
      : showBarModalBottomSheet<T>(
          context: context,
          settings: settings,
          barrierColor: Colors.black45,
          backgroundColor: backgroundColor ?? Colors.transparent,
          builder: (context) => ConditionalParentWidget(
            condition: !expand,
            child: builder(context),
            conditionalBuilder: (child) => SizedBox(
              height: height,
              child: child,
            ),
          ),
        );
}
