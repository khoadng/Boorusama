// Package imports:
import 'package:kurumi/material.dart';

// Project imports:
import 'analytics/widgets.dart';
import 'backups/auto/trigger.dart';
import 'debug/widgets.dart';
import '../foundation/networking.dart';
import 'themes/colors/dynamic_color.dart';

class BoorusamaExternalEffects extends StatelessWidget {
  const BoorusamaExternalEffects({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBridge(
      child: AnalyticsScope(
        child: AutoBackupAppLifecycle(
          child: NetworkListener(
            child: DiagnosticContextScope(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
