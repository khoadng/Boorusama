// Dart imports:
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

// Package imports:
import 'package:web/web.dart' as web;

Future<String> derivePinKey({
  required String pin,
  required String salt,
  required int iterations,
}) async {
  final subtle = web.window.crypto.subtle;
  final key = await subtle
      .importKey(
        'raw',
        Uint8List.fromList(utf8.encode(pin)).toJS,
        'PBKDF2'.toJS,
        false,
        ['deriveBits'.toJS].toJS,
      )
      .toDart;
  final algorithm =
      <String, Object>{
            'name': 'PBKDF2',
            'hash': 'SHA-256',
            'salt': Uint8List.fromList(base64Url.decode(salt)).toJS,
            'iterations': iterations,
          }.jsify()!
          as JSObject;
  final buffer = await subtle.deriveBits(algorithm, key, 256).toDart;
  final bytes = buffer.toDart.asUint8List();

  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}
