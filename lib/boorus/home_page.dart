// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/pages/home/danbooru_bottom_bar.dart';
import 'package:boorusama/boorus/danbooru/pages/home/danbooru_home_page.dart';
import 'package:boorusama/boorus/danbooru/pages/home/other_features_page.dart';
import 'package:boorusama/boorus/e621/e621_provider.dart';
import 'package:boorusama/boorus/e621/pages/home/e621_bottom_bar.dart';
import 'package:boorusama/boorus/e621/pages/home/e621_home_page.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/pages/home/gelbooru_home_page.dart';
import 'package:boorusama/boorus/home_page_scope.dart';
import 'package:boorusama/boorus/moebooru/moebooru_provider.dart';
import 'package:boorusama/boorus/moebooru/pages/home.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/permissions/permissions.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/navigation_tile.dart';

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

    return Builder(
      builder: (context) {
        final config = ref.watch(currentBooruConfigProvider);
        final booru = ref.watch(currentBooruProvider);

        switch (booru.booruType) {
          case BooruType.unknown:
            return const Center(
              child: Text('Unknown booru'),
            );
          case BooruType.e621:
          case BooruType.e926:
            return E621Provider(
              builder: (context) => HomePageScope(
                bottomBar: (context, controller) => isMobilePlatform()
                    ? ValueListenableBuilder(
                        valueListenable: controller,
                        builder: (context, value, child) => E621BottomBar(
                          initialValue: value,
                          onTabChanged: (value) => controller.goToTab(value),
                          isAuthenticated:
                              ref.watch(authenticationProvider).isAuthenticated,
                        ),
                      )
                    : ValueListenableBuilder(
                        valueListenable: controller,
                        builder: (context, index, child) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            NavigationTile(
                              value: 0,
                              index: index,
                              selectedIcon: const Icon(Icons.dashboard),
                              icon: const Icon(
                                Icons.dashboard_outlined,
                              ),
                              title: const Text('Home'),
                              onTap: (value) => controller.goToTab(value),
                            ),
                            NavigationTile(
                              value: 1,
                              index: index,
                              selectedIcon: const Icon(Icons.explore),
                              icon: const Icon(Icons.explore_outlined),
                              title: const Text('Popular'),
                              onTap: (value) => controller.goToTab(value),
                            ),
                            if (ref
                                .watch(authenticationProvider)
                                .isAuthenticated)
                              NavigationTile(
                                value: 2,
                                index: index,
                                selectedIcon: const Icon(Icons.favorite),
                                icon: const Icon(Icons.favorite_border),
                                title: const Text('Favorites'),
                                onTap: (value) => controller.goToTab(value),
                              ),
                          ],
                        ),
                      ),
                builder: (context, tab, controller) => CustomContextMenuOverlay(
                  child: E621HomePage(
                    key: ValueKey(config.id),
                    controller: controller,
                    bottomBar: tab,
                  ),
                ),
              ),
            );
          case BooruType.aibooru:
          case BooruType.danbooru:
          case BooruType.safebooru:
          case BooruType.testbooru:
            return HomePageScope(
              bottomBar: (context, controller) => isMobilePlatform()
                  ? ValueListenableBuilder(
                      valueListenable: controller,
                      builder: (context, value, child) => DanbooruBottomBar(
                        initialValue: value,
                        onTabChanged: (value) => controller.goToTab(value),
                      ),
                    )
                  : ValueListenableBuilder(
                      valueListenable: controller,
                      builder: (context, index, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          NavigationTile(
                            value: 0,
                            index: index,
                            selectedIcon: const Icon(Icons.dashboard),
                            icon: const Icon(
                              Icons.dashboard_outlined,
                            ),
                            title: const Text('Home'),
                            onTap: (value) => controller.goToTab(value),
                          ),
                          NavigationTile(
                            value: 1,
                            index: index,
                            selectedIcon: const Icon(Icons.explore),
                            icon: const Icon(Icons.explore_outlined),
                            title: const Text('Explore'),
                            onTap: (value) => controller.goToTab(value),
                          ),
                          const Divider(),
                          const DanbooruOtherFeaturesWidget(),
                        ],
                      ),
                    ),
              builder: (context, tab, controller) => DanbooruProvider(
                builder: (context) {
                  return CustomContextMenuOverlay(
                    child: DanbooruHomePage(
                      key: ValueKey(config.id),
                      controller: controller,
                      bottomBar: tab,
                    ),
                  );
                },
              ),
            );
          case BooruType.gelbooru:
          case BooruType.rule34xxx:
            final gkey = ValueKey(config.id);

            return HomePageScope(
              builder: (context, tab, controller) => GelbooruProvider(
                key: gkey,
                builder: (gcontext) => CustomContextMenuOverlay(
                  child: GelbooruHomePage(
                    key: gkey,
                    controller: controller,
                  ),
                ),
              ),
            );
          case BooruType.konachan:
          case BooruType.yandere:
          case BooruType.sakugabooru:
          case BooruType.lolibooru:
            final gkey = ValueKey(config.id);

            return HomePageScope(
              bottomBar: (context, controller) => isMobilePlatform()
                  ? ValueListenableBuilder(
                      valueListenable: controller,
                      builder: (context, value, child) => MoebooruBottomBar(
                        initialValue: value,
                        onTabChanged: (value) => controller.goToTab(value),
                      ),
                    )
                  : ValueListenableBuilder(
                      valueListenable: controller,
                      builder: (context, index, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          NavigationTile(
                            value: 0,
                            index: index,
                            selectedIcon: const Icon(Icons.dashboard),
                            icon: const Icon(
                              Icons.dashboard_outlined,
                            ),
                            title: const Text('Home'),
                            onTap: (value) => controller.goToTab(value),
                          ),
                          NavigationTile(
                            value: 1,
                            index: index,
                            selectedIcon: const Icon(Icons.explore),
                            icon: const Icon(Icons.explore_outlined),
                            title: const Text('Popular'),
                            onTap: (value) => controller.goToTab(value),
                          ),
                          NavigationTile(
                            value: 2,
                            index: index,
                            selectedIcon:
                                const Icon(Icons.local_fire_department),
                            icon: const Icon(
                                Icons.local_fire_department_outlined),
                            title: const Text('Hot'),
                            onTap: (value) => controller.goToTab(value),
                          ),
                        ],
                      ),
                    ),
              builder: (context, tab, controller) => MoebooruProvider(
                key: gkey,
                builder: (gcontext) => CustomContextMenuOverlay(
                  child: MoebooruHomePage(
                    key: gkey,
                    controller: controller,
                    bottomBar: tab,
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}
