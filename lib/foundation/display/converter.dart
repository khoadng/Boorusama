// Project imports:
import 'types.dart';

ScreenSize screenWidthToDisplaySize(double width) => switch (width) {
      <= 600 => ScreenSize.small,
      <= 1100 => ScreenSize.medium,
      <= 1500 => ScreenSize.large,
      _ => ScreenSize.veryLarge,
    };
