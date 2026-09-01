// Dart imports:
import 'dart:convert';
import 'dart:isolate';

// Package imports:
import 'package:crypto/crypto.dart';

Future<String> derivePinKey({
  required String pin,
  required String salt,
  required int iterations,
}) => Isolate.run(
  () => _derivePbkdf2Sha256(
    pin: pin,
    salt: salt,
    iterations: iterations,
  ),
);

String _derivePbkdf2Sha256({
  required String pin,
  required String salt,
  required int iterations,
}) {
  final hmac = Hmac(sha256, utf8.encode(pin));
  final saltBytes = base64Url.decode(salt);
  final firstBlock = [...saltBytes, 0, 0, 0, 1];
  var u = hmac.convert(firstBlock).bytes;
  final derived = List<int>.from(u);

  for (var i = 1; i < iterations; i++) {
    u = hmac.convert(u).bytes;
    for (var byte = 0; byte < derived.length; byte++) {
      derived[byte] ^= u[byte];
    }
  }

  return Digest(derived).toString();
}
