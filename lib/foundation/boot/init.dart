// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:path_provider/path_provider.dart';

// Project imports:
import '../platform.dart';

Future<String> initDbDirectory() async {
  if (isWeb()) {
    return '';
  }

  final dir = isAndroid()
      ? await getApplicationDocumentsDirectory()
      : await getApplicationSupportDirectory();

  return dir.path;
}

Future<void> initCert() async {
  if (!isAndroid()) {
    return;
  }

  try {
    // https://stackoverflow.com/questions/69511057/flutter-on-android-7-certificate-verify-failed-with-letsencrypt-ssl-cert-after-s
    // On Android 7 and below, the Let's Encrypt certificate is not trusted by default and needs to be added manually.
    final cert = await rootBundle.load('assets/ca/isrgrootx1.pem');

    SecurityContext.defaultContext.setTrustedCertificatesBytes(
      cert.buffer.asUint8List(),
    );
  } catch (e) {
    // ignore errors here, maybe it's already trusted
  }
}

Future<void> initPlatform() async {
  await initCert();
}
