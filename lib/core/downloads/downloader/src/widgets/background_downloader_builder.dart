// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../router.dart';
import 'background_downloader_scope.dart';

class BackgroundDownloaderBuilder extends ConsumerWidget {
  const BackgroundDownloaderBuilder({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackgroundDownloaderScope(
      onTapNotification: (task, notificationType) {
        ref.router.go(
          Uri(
            path: '/download_manager',
            queryParameters: {
              'filter': notificationType.name,
            },
          ).toString(),
        );
      },
      child: child,
    );
  }
}
