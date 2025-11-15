// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../../foundation/permissions.dart';
import '../../../../foundation/platform.dart';
import '../../../../foundation/toast.dart';
import '../../../boorus/engine/providers.dart';
import '../../../bulk_downloads/providers.dart';
import '../../../changelogs/routes.dart';
import '../../../config_widgets/website_logo.dart';
import '../../../configs/config/providers.dart';
import '../../../configs/config/types.dart';
import '../../../configs/manage/providers.dart';
import '../../../configs/manage/widgets.dart';
import '../../../premiums/widgets.dart';
import '../../../settings/providers.dart';
import '../../../themes/theme/types.dart';
import 'empty_booru_config_home_page.dart';

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
      showChangelogDialogIfNeeded(context, ref);
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
                label: context.t.settings.open_app_settings,
                onPressed: openAppSettings,
              ),
              behavior: SnackBarBehavior.fixed,
              content: Text(context.t.download.storage_permission_explanation),
            );
            ref
                .read(deviceStoragePermissionProvider.notifier)
                .markNotificationAsRead();
          }
        },
      );
    }

    return _NotificationScope(
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
                      builder: (_, bottom, _) => bottom
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

class _NotificationScope extends StatelessWidget {
  const _NotificationScope({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BulkDownloadNotificationScope(
      child: LayoutPreviewNotificationScope(
        child: child,
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
    final hideLabel = ref.watch(
      settingsProvider.select(
        (value) => value.booruConfigLabelVisibility.hideBooruConfigLabel,
      ),
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: builder(
        context,
        pos.isBottom,
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
    final booruBuilder = ref.watch(booruBuilderProvider(config.auth));

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
              context.t.booru.invalid_selected_profile,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (availableConfigs.isNotEmpty)
              Text(
                context.t.booru.invalid_selected_profile_selection_request,
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
                      ref
                          .read(currentBooruConfigProvider.notifier)
                          .update(
                            config,
                          );
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ConfigAwareWebsiteLogo(url: config.url),
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
