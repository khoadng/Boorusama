// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../platform.dart';
import 'screen_size.dart';

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
      (this == PreferredLayout.platform && !isMobilePlatform());
}

extension DisplayX on BuildContext {
  Screen get screen => Screen.of(this);
  Orientation get orientation => MediaQuery.orientationOf(this);

  bool get isLargeScreen =>
      kPreferredLayout.isDesktop ||
      (kPreferredLayout.isMobile && MediaQuery.sizeOf(this).width > 880);
}

extension OrientationX on Orientation {
  bool get isLandscape => this == Orientation.landscape;
  bool get isPortrait => this == Orientation.portrait;
}
