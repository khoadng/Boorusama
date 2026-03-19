// Dart imports:
import 'dart:js_interop';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:web/web.dart' as web;

// Project imports:
import 'core/boorusama_app.dart';
import 'foundation/filesystem.dart';
import 'foundation/iap/iap.dart';

void main() {
  web.document.addEventListener(
    'contextmenu',
    (web.Event event) {
      event.preventDefault();
    }.toJS,
  );

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    BoorusamaApp(
      fileSystem: const IoFileSystem(),
      iapFunc: () => initDummyIap(),
    ),
  );
}
