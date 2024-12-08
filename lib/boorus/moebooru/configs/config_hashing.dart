// Project imports:
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/foundation/crypto.dart';
import 'package:boorusama/foundation/functional.dart';

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
