typedef AndroidVersion = int;

bool? hasScopedStorage(AndroidVersion? version) {
  if (version == null) return null;

  return version >= 30;
}

bool? hasGranularMediaPermissions(AndroidVersion? version) {
  if (version == null) return null;

  return version >= 33;
}
