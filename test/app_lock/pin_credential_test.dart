// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import 'package:boorusama/foundation/pincode/src/pin_credential.dart';

void main() {
  group('PinCredentialRepository', () {
    late Directory tempDir;
    late Box<String> box;
    late PinCredentialRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('app_lock_test_');
      box = await Hive.openBox<String>(
        'app_lock_credentials_test',
        path: tempDir.path,
      );
      repository = PinCredentialRepository(Future.value(box));
    });

    tearDown(() async {
      await box.close();
      await tempDir.delete(recursive: true);
    });

    test('stores and verifies PIN without storing raw PIN', () async {
      await repository.setPin('1234');

      expect(await repository.hasPin(), isTrue);
      expect(await repository.verifyPin('1234'), isTrue);
      expect(await repository.verifyPin('4321'), isFalse);

      final credential = await repository.getPinCredential();
      expect(credential, isNotNull);
      expect(credential!.verifier, isNot(contains('1234')));
    });

    test('clears PIN credential', () async {
      await repository.setPin('1234');
      await repository.clearPin();

      expect(await repository.hasPin(), isFalse);
      expect(await repository.verifyPin('1234'), isFalse);
    });
  });

  group('PinKeyDeriver', () {
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
  });
}
