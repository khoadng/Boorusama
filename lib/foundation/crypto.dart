// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:crypto/crypto.dart';

// Project imports:
import 'package:boorusama/boorus/core/boorus/boorus.dart';

String hashPasswordSHA1({
  required String salt,
  required String password,
  required String Function(String salt, String password) hashStringBuilder,
}) {
  var hashedString = hashStringBuilder(salt, password);
  var bytes = utf8.encode(hashedString);
  var hash = sha1.convert(bytes);
  var hashedPassword = hash.toString();

  return hashedPassword;
}

String hashBooruPasswordSHA1({
  required Booru booru,
  required BooruFactory booruFactory,
  required String password,
}) =>
    hashPasswordSHA1(
      salt: booruFactory.getSalt(booru),
      password: password,
      hashStringBuilder: (salt, password) => salt.replaceAll('{0}', password),
    );
