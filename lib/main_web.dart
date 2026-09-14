// Dart imports:
import 'dart:js_interop';

// Package imports:
import 'package:kurumi/material.dart';
import 'package:web/web.dart' as web;

// Project imports:
import 'core/bootstrap/production_boorusama_bootstrap.dart';
import 'core/bootstrap/bootstrap_host.dart';
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
    const BoorusamaBootstrapHost(
      bootstrap: ProductionBoorusamaBootstrap(
        fileSystem: IoFileSystem(),
        iapFactory: initDummyIap,
      ),
    ),
  );
}
