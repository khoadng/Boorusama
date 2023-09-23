// Flutter imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/booru_selector.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/permissions.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    if (isAndroid() || isIOS()) {
      ref.listen(
        deviceStoragePermissionProvider,
        (previous, state) {
          if (state.storagePermission == PermissionStatus.permanentlyDenied &&
              !state.isNotificationRead) {
            showSimpleSnackBar(
              context: context,
              action: SnackBarAction(
                label: 'download.open_app_settings'.tr(),
                onPressed: openAppSettings,
              ),
              behavior: SnackBarBehavior.fixed,
              content:
                  const Text('download.storage_permission_explanation').tr(),
            );
            ref
                .read(deviceStoragePermissionProvider.notifier)
                .markNotificationAsRead();
          }
        },
      );
    }

    ref.listen(
      bulkDownloadStateProvider.select((value) => value.downloadStatuses),
      (previous, next) {
        if (previous == null) return;
        if (previous.values.any((e) => e is! BulkDownloadDone) &&
            next.values.isNotEmpty &&
            next.values.all((t) => t is BulkDownloadDone)) {
          showSimpleSnackBar(
            context: context,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'generic.view'.tr(),
              onPressed: () => goToBulkDownloadPage(context, [], ref: ref),
            ),
            behavior: SnackBarBehavior.fixed,
            content:
                const Text('download.bulk.all_done_notification_message').tr(),
          );
        }
      },
    );

    final config = ref.watch(currentBooruConfigProvider);

    return OrientationBuilder(
      builder: (context, orientation) => ConditionalParentWidget(
        condition: isDesktopPlatform() || orientation.isLandscape,
        conditionalBuilder: (child) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BooruSelector(),
            const VerticalDivider(
              thickness: 1,
              width: 1,
            ),
            Expanded(
              child: child,
            )
          ],
        ),
        child: _Boorus(
          key: ValueKey(config),
          ref: ref,
          config: config,
        ),
      ),
    );
  }
}

class _Boorus extends StatelessWidget {
  const _Boorus({
    super.key,
    required this.ref,
    required this.config,
  });

  final WidgetRef ref;
  final BooruConfig config;

  @override
  Widget build(BuildContext context) {
    if (booruBuilders.containsKey(config.booruType)) {
      return booruBuilders[config.booruType]!.homePageBuilder(context, config);
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Not implemented'),
        ),
      );
    }
  }
}

class HomePageController extends ValueNotifier<int> {
  HomePageController({
    required this.scaffoldKey,
  }) : super(0);

  final GlobalKey<ScaffoldState> scaffoldKey;

  void goToTab(int index) {
    value = index;
  }

  void openMenu() {
    scaffoldKey.currentState!.openDrawer();
  }
}
