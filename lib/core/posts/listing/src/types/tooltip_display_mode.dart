enum TooltipDisplayMode {
  enabled,
  disabled;

  static TooltipDisplayMode? tryParse(dynamic value) => switch (value) {
    'enabled' || '0' || 0 => enabled,
    'disabled' || '1' || 1 => disabled,
    _ => null,
  };

  bool get isEnabled => this == enabled;

  dynamic toData() => index;
}
