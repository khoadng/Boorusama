// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/foundation/pincode/src/pin_credential.dart';

void main() {
  test('matches the PBKDF2-HMAC-SHA256 reference vector', () async {
    final verifier = await const PinKeyDeriver().derive(
      pin: 'password',
      salt: base64Url.encode(utf8.encode('salt')),
      iterations: 2,
    );

    expect(
      verifier,
      'ae4d0c95af6b46d32d0adff928f06dd'
      '02a303f8ef3c251dfd6e2d85a95474c43',
    );
  });
}
