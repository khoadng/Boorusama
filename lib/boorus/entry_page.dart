// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../core/cache/providers.dart';
import '../core/changelogs/utils.dart';
import '../core/configs/config.dart';
import '../core/configs/current.dart';
import '../core/configs/manage.dart';
import '../core/configs/ref.dart';
import '../core/configs/widgets.dart';
import '../core/downloads/notifications.dart';
import '../core/home/empty_booru_config_home_page.dart';
import '../core/settings.dart';
import '../core/settings/data.dart';
import '../core/theme.dart';
import '../core/widgets/widgets.dart';
import '../foundation/display.dart';
import '../foundation/permissions.dart';
import '../foundation/platform.dart';
import '../foundation/toast.dart';
import 'booru_builder.dart';

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
      final miscBox = ref.read(miscDataBoxProvider);

      ref.showChangelogDialogIfNeeded(miscBox);
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

    return BulkDownloadNotificationScope(
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (context.isLargeScreen) ...[
                  SafeArea(
                    right: false,
                    bottom: false,
                    child: _SidebarSettingsListener(
                      builder: (_, bottom, __) => bottom
                          ? const SizedBox.shrink()
                          : const BooruSelector(),
                    ),
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
                ],
                const Expanded(
                  child: _Boorus(),
                ),
              ],
            ),
          ),
          if (context.isLargeScreen)
            _SidebarSettingsListener(
              builder: (_, bottom, hideLabel) => bottom
                  ? SizedBox(
                      height: kBottomNavigationBarHeight - (hideLabel ? 4 : -8),
                      child: const BooruSelector(
                        direction: Axis.horizontal,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

class _SidebarSettingsListener extends ConsumerWidget {
  const _SidebarSettingsListener({required this.builder});

  final Widget Function(BuildContext context, bool isBottom, bool hideLabel)
      builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = ref.watch(
      settingsProvider.select((value) => value.booruConfigSelectorPosition),
    );
    final hideLabel = ref
        .watch(settingsProvider.select((value) => value.hideBooruConfigLabel));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: builder(
        context,
        pos == BooruConfigSelectorPosition.bottom,
        hideLabel,
      ),
    );
  }
}

class _Boorus extends ConsumerWidget {
  const _Boorus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final booruBuilder = ref.watch(currentBooruBuilderProvider);

    if (booruBuilder != null) {
      return Builder(
        key: ValueKey(config),
        builder: (context) => booruBuilder.homePageBuilder(context),
      );
    } else {
      final availableConfigs = ref.watch(booruConfigProvider);
      return availableConfigs.isNotEmpty
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (availableConfigs.isNotEmpty == true)
              Text(
                'Select a profile from the list below to continue',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.hintColor,
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
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BooruLogo(source: config.url),
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
