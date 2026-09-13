import 'package:material_ui/material_ui.dart';

enum KurumiScreenSize {
  small,
  medium,
  large,
  veryLarge,
}

class KurumiScreen {
  const KurumiScreen._(this.context);

  factory KurumiScreen.of(BuildContext context) => KurumiScreen._(context);

  final BuildContext context;

  Size get _size => MediaQuery.sizeOf(context);

  KurumiScreenSize get size => sizeForWidth(_size.width);

  KurumiScreenSize nextBreakpoint() => switch (size) {
    KurumiScreenSize.small => KurumiScreenSize.medium,
    KurumiScreenSize.medium => KurumiScreenSize.large,
    KurumiScreenSize.large => KurumiScreenSize.veryLarge,
    KurumiScreenSize.veryLarge => KurumiScreenSize.veryLarge,
  };

  static KurumiScreenSize sizeForWidth(double width) => switch (width) {
    <= 600 => KurumiScreenSize.small,
    <= 1100 => KurumiScreenSize.medium,
    <= 1500 => KurumiScreenSize.large,
    _ => KurumiScreenSize.veryLarge,
  };
}

extension KurumiScreenSizeX on KurumiScreenSize {
  bool get isLarge => this != KurumiScreenSize.small;
}
