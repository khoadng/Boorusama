// Package imports:
import 'package:kurumi/material.dart';

// Project imports:
import 'core/bootstrap/production_boorusama_bootstrap.dart';
import 'core/bootstrap/bootstrap_host.dart';
import 'foundation/app_update/providers.dart';
import 'foundation/filesystem.dart';
import 'foundation/iap/iap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const BoorusamaBootstrapHost(
      bootstrap: ProductionBoorusamaBootstrap(
        fileSystem: IoFileSystem(),
        isFossBuild: true,
        iapFactory: initDummyIap,
        appUpdateChecker: createDefaultAppUpdateChecker,
      ),
    ),
  );
}
