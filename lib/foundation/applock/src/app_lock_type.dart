enum AppLockType {
  none,
  biometrics,
  pin;

  factory AppLockType.parse(dynamic value) => switch (value) {
    'none' || '0' || 0 => none,
    'biometrics' || '1' || 1 => biometrics,
    'pin' || '2' || 2 => pin,
    _ => defaultValue,
  };

  static const AppLockType defaultValue = none;

  bool get isBiometric => this == biometrics;
  bool get appLockEnabled => isBiometric;

  dynamic toData() => index;
}
