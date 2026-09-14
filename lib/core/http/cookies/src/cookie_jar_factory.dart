// Package imports:
import 'package:coreutils/coreutils.dart';

abstract interface class CookieJarFactory {
  Future<CookieJar> create();
}
