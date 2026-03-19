// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'core/boorusama_app.dart';
import 'foundation/filesystem.dart';
import 'foundation/iap/iap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    BoorusamaApp(
      fileSystem: const IoFileSystem(),
      isFossBuild: true,
      iapFunc: () => initDummyIap(),
    ),
  );
}
