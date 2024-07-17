// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/app_update/app_update.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/permissions.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

class EntryPage extends ConsumerStatefulWidget {
  const EntryPage({
    super.key,
  });

  @override
  ConsumerState<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends ConsumerState<EntryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.showChangelogDialogIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isAndroid() || isIOS()) {
      ref.listen(
        deviceStoragePermissionProvider,
        (previous, state) {
          final value = state.value;
          final isPermenantlyDenied =
              value?.storagePermission == PermissionStatus.permanentlyDenied;
          final isNotRead = !(value?.isNotificationRead ?? false);

          if (isPermenantlyDenied && isNotRead) {
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

    final config = ref.watchConfig;

    ref.listen(
      bulkDownloadStateProvider(config)
          .select((value) => value.downloadStatuses),
      (previous, next) {
        if (previous == null) return;
        if (previous.values.any((e) => e is! DownloadDone) &&
            next.values.isNotEmpty &&
            next.values.all((t) => t is DownloadDone)) {
          showSimpleSnackBar(
            context: context,
            duration: AppDurations.longToast,
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

    return OrientationBuilder(
      builder: (context, orientation) => ConditionalParentWidget(
        condition: kPreferredLayout.isDesktop ||
            (kPreferredLayout.isMobile && orientation.isLandscape),
        conditionalBuilder: (child) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConditionalParentWidget(
              condition: orientation.isLandscape,
              conditionalBuilder: (child) => SafeArea(
                right: false,
                child: child,
              ),
              child: const BooruSelector(),
            ),
            const SafeArea(
              bottom: false,
              left: false,
              right: false,
              child: VerticalDivider(
                thickness: 1,
                width: 1,
              ),
            ),
            Expanded(
              child: child,
            )
          ],
        ),
        child: const _Boorus(),
      ),
    );
  }
}

class _Boorus extends ConsumerWidget {
  const _Boorus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final booruBuilder = ref.watch(booruBuilderProvider);

    if (booruBuilder != null) {
      return Builder(
        key: ValueKey(config),
        builder: (context) => booruBuilder.homePageBuilder(context, config),
      );
    } else {
      final availableConfigs = ref.watch(booruConfigProvider);
      return availableConfigs != null && availableConfigs.isNotEmpty
          ? _buildInvalid(availableConfigs, ref)
          : const EmptyBooruConfigHomePage();
    }
  }

  Widget _buildInvalid(List<BooruConfig> availableConfigs, WidgetRef ref) {
    final context = ref.context;

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text(
              'Current selected profile is invalid',
              style: context.textTheme.titleLarge,
            ),
            if (availableConfigs.isNotEmpty == true)
              Text(
                'Select a profile from the list below to continue',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.theme.hintColor,
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: availableConfigs.length,
                itemBuilder: (context, index) {
                  final config = availableConfigs[index];
                  return ListTile(
                    title: Text(config.name),
                    subtitle: Text(config.url),
                    onTap: () {
                      ref.read(currentBooruConfigProvider.notifier).update(
                            config,
                          );
                    },
                    leading: PostSource.from(config.url).whenWeb(
                      (source) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BooruLogo(source: source),
                      ),
                      () => const SizedBox.shrink(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
