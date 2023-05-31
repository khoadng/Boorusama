// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/ui/home/danbooru_home_page.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/ui/home/gelbooru_home_page.dart';
import 'package:boorusama/boorus/moebooru/moebooru_provider.dart';
import 'package:boorusama/boorus/moebooru/ui/home.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/permissions.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/downloads.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/home/side_bar_menu.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/functional.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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

    return Scaffold(
      key: scaffoldKey,
      drawer: const SideBarMenu(
        width: 300,
        popOnSelect: true,
        padding: EdgeInsets.zero,
      ),
      body: Builder(
        builder: (context) {
          final config = ref.watch(currentBooruConfigProvider);
          final booru = ref.watch(currentBooruProvider);

          switch (booru.booruType) {
            case BooruType.unknown:
              return const Center(
                child: Text('Unknown booru'),
              );
            case BooruType.aibooru:
            case BooruType.danbooru:
            case BooruType.safebooru:
            case BooruType.testbooru:
              return DanbooruProvider(
                builder: (context) {
                  return CustomContextMenuOverlay(
                    child: DanbooruHomePage(
                      onMenuTap: _onMenuTap,
                      key: ValueKey(config.id),
                    ),
                  );
                },
              );
            case BooruType.gelbooru:
              final gkey = ValueKey(config.id);

              return GelbooruProvider(
                key: gkey,
                builder: (gcontext) => CustomContextMenuOverlay(
                  child: GelbooruHomePage(
                    key: gkey,
                    onMenuTap: _onMenuTap,
                  ),
                ),
              );
            case BooruType.konachan:
            case BooruType.yandere:
            case BooruType.sakugabooru:
              final gkey = ValueKey(config.id);

              return MoebooruProvider(
                key: gkey,
                builder: (gcontext) => CustomContextMenuOverlay(
                  child: MoebooruHomePage(
                    key: gkey,
                    onMenuTap: _onMenuTap,
                  ),
                ),
              );
          }
        },
      ),
    );
  }

  void _onMenuTap() {
    scaffoldKey.currentState!.openDrawer();
  }
}
