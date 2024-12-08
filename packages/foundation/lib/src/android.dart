typedef AndroidVersion = int;

abstract class AndroidVersions {
  static const int android6 = 23; // Marshmallow
  static const int android7_0 = 24; // Nougat
  static const int android7_1 = 25; // Nougat 1
  static const int android8_0 = 26; // Oreo
  static const int android8_1 = 27; // Oreo 1
  static const int android9 = 28; // Pie
  static const int android10 = 29; // Android 10
  static const int android11 = 30; // Android 11
  static const int android12 = 31; // Android 12
  static const int android12L = 32; // Android 12L
  static const int android13 = 33; // Android 13
  static const int android14 = 34; // Android 14
  static const int android15 = 35; // Android 15
}

bool? hasScopedStorage(AndroidVersion? version) {
  if (version == null) return null;

  return version >= AndroidVersions.android11;
}

bool? hasGranularMediaPermissions(AndroidVersion? version) {
  if (version == null) return null;

  return version >= AndroidVersions.android13;
}
