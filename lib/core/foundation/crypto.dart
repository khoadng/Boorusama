// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:crypto/crypto.dart';

String hashPasswordSHA1({
  required String salt,
  required String password,
  required String Function(String salt, String password) hashStringBuilder,
}) {
  final hashedString = hashStringBuilder(salt, password);
  final bytes = utf8.encode(hashedString);
  final hash = sha1.convert(bytes);
  final hashedPassword = hash.toString();

  return hashedPassword;
}
