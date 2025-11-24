// Dart imports:
import 'dart:js_interop';

// Package imports:
import 'package:web/web.dart' as web;

// Project imports:
import 'boot.dart';
import 'foundation/boot.dart';
import 'foundation/iap/iap.dart';
import 'foundation/loggers.dart';

void main() async {
  web.document.addEventListener(
    'contextmenu',
    (web.Event event) {
      event.preventDefault();
    }.toJS,
  );

  await initializeApp(
    bootFunc: (data) {
      data.logger.debugBoot('Booting Web version');
      return boot(
        data.copyWith(
          iapFunc: () => initDummyIap(),
        ),
      );
    },
  );
}
