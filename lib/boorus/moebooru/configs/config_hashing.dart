// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/boorus.dart';
import '../../../foundation/crypto.dart';

String hashBooruPasswordSHA1({
  required String url,
  required Booru? booru,
  required String password,
}) =>
    booru!.getSalt(url).toOption().fold(
          () => '',
          (salt) => hashPasswordSHA1(
            salt: salt,
            password: password,
            hashStringBuilder: (salt, password) =>
                salt.replaceAll('{0}', password),
          ),
        ) ??
    '';
