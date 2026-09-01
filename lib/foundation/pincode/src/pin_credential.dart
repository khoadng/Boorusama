// Dart imports:
import 'dart:convert';
import 'dart:math';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import 'pin_key_deriver_native.dart'
    if (dart.library.js_interop) 'pin_key_deriver_web.dart';

const _pinCredentialKey = 'pin_credential';
const _pinCredentialVersion = 2;
const _pinDerivationIterations = 30000;
const _pinSaltLength = 32;

final pinCredentialRepositoryProvider = Provider<PinCredentialRepository>(
  (ref) => PinCredentialRepository(
    Hive.openBox<String>('app_lock_credentials'),
  ),
  name: 'pinCredentialRepositoryProvider',
);

class PinCredential {
  const PinCredential({
    required this.version,
    required this.salt,
    required this.verifier,
    required this.iterations,
    required this.createdAt,
  });

  factory PinCredential.fromJson(Map<String, dynamic> json) => PinCredential(
    version: json['version'] as int? ?? 0,
    salt: json['salt'] as String? ?? '',
    verifier: json['verifier'] as String? ?? '',
    iterations: json['iterations'] as int? ?? _pinDerivationIterations,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );

  final int version;
  final String salt;
  final String verifier;
  final int iterations;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'version': version,
    'salt': salt,
    'verifier': verifier,
    'iterations': iterations,
    'createdAt': createdAt.toIso8601String(),
  };
}

class PinCredentialRepository {
  PinCredentialRepository(
    this._box, {
    this.keyDeriver = const PinKeyDeriver(),
  });

  final Future<Box<String>> _box;
  final PinKeyDeriver keyDeriver;

  Future<bool> hasPin() async => await getPinCredential() != null;

  Future<PinCredential?> getPinCredential() async {
    final box = await _box;
    final value = box.get(_pinCredentialKey);
    if (value == null || value.isEmpty) return null;

    try {
      final json = jsonDecode(value);
      if (json is! Map<String, dynamic>) return null;

      final credential = PinCredential.fromJson(json);
      if (credential.version != _pinCredentialVersion ||
          credential.salt.isEmpty ||
          credential.verifier.isEmpty ||
          credential.iterations != _pinDerivationIterations ||
          !_hasValidSalt(credential.salt) ||
          !_isSha256Hex(credential.verifier)) {
        return null;
      }

      return credential;
    } catch (_) {
      return null;
    }
  }

  Future<void> setPin(String pin) async {
    final box = await _box;
    final salt = _randomSalt();
    final credential = PinCredential(
      version: _pinCredentialVersion,
      salt: salt,
      verifier: await keyDeriver.derive(
        pin: pin,
        salt: salt,
        iterations: _pinDerivationIterations,
      ),
      iterations: _pinDerivationIterations,
      createdAt: DateTime.now(),
    );

    await box.put(_pinCredentialKey, jsonEncode(credential.toJson()));
  }

  Future<bool> verifyPin(String pin) async {
    final credential = await getPinCredential();
    if (credential == null) return false;

    final verifier = await keyDeriver.derive(
      pin: pin,
      salt: credential.salt,
      iterations: credential.iterations,
    );

    return _constantTimeEquals(verifier, credential.verifier);
  }

  Future<void> clearPin() async {
    final box = await _box;
    await box.delete(_pinCredentialKey);
  }
}

String _randomSalt() {
  final random = Random.secure();
  final bytes = List<int>.generate(
    _pinSaltLength,
    (_) => random.nextInt(256),
  );
  return base64Url.encode(bytes);
}

class PinKeyDeriver {
  const PinKeyDeriver();

  Future<String> derive({
    required String pin,
    required String salt,
    required int iterations,
  }) {
    if (iterations <= 0) {
      throw ArgumentError.value(iterations, 'iterations', 'Must be positive');
    }

    return derivePinKey(
      pin: pin,
      salt: salt,
      iterations: iterations,
    );
  }
}

bool _hasValidSalt(String salt) {
  try {
    return base64Url.decode(salt).length == _pinSaltLength;
  } catch (_) {
    return false;
  }
}

bool _isSha256Hex(String value) => RegExp(r'^[0-9a-f]{64}$').hasMatch(value);

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;

  var mismatch = 0;
  for (var i = 0; i < a.length; i++) {
    mismatch |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }

  return mismatch == 0;
}
