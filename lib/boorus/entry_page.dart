// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/app_update/app_update.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/permissions.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';

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
        settingsProvider.select((value) => value.booruConfigSelectorPosition));
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
    final config = ref.watchConfig;
    final booruBuilder = ref.watch(booruBuilderProvider);

    if (booruBuilder != null) {
      return Builder(
        key: ValueKey(config),
        builder: (context) => booruBuilder.homePageBuilder(context, config),
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
              style: context.textTheme.titleLarge,
            ),
            if (availableConfigs.isNotEmpty == true)
              Text(
                'Select a profile from the list below to continue',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colorScheme.hintColor,
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
