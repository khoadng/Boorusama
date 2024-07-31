import 'package:version/version.dart';

extension VersionX on Version? {
  bool significantlyLowerThan(Version? other) {
    final v = this;
    final o = other;

    if (v == null) return false;
    if (o == null) return false;

    if (v.major < o.major) return true;

    if (v.major == o.major && v.minor < o.minor) return true;

    return false;
  }
}
