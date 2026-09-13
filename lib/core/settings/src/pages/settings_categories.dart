// Package imports:
import 'package:kurumi/material.dart';

// Project imports:
import '../../../developer_options/widgets.dart';
import '../generated/settings_category.g.dart';
import '../widgets/settings_page_scaffold.dart';
import 'accessibility_page.dart';
import 'app_lock_settings_page.dart';
import 'appearance/appearance_page.dart';
import 'backup_and_restore_page.dart';
import 'data_and_storage_page.dart';
import 'download_page.dart';
import 'image_viewer_page.dart';
import 'language_page.dart';
import 'privacy_page.dart';
import 'search_settings_page.dart';

List<SettingEntry> settingsCategories(
  BuildContext context, {
  required bool showDeveloperOptions,
}) => [
  for (final category in [
    ...SettingsCategory.appMenu,
    if (showDeveloperOptions) SettingsCategory.developerOptions,
  ])
    settingsCategoryEntry(context, category),
];

SettingEntry settingsCategoryEntry(
  BuildContext context,
  SettingsCategory category,
) => SettingEntry(
  id: category.id,
  name: category.appRoute,
  title: category.title(context, SettingsSearchScope.app),
  icon: category.icon,
  content: switch (category) {
    SettingsCategory.appearance => const AppearancePage(),
    SettingsCategory.language => const LanguagePage(),
    SettingsCategory.download => const DownloadPage(),
    SettingsCategory.dataAndStorage => const DataAndStoragePage(),
    SettingsCategory.backupAndRestore => const BackupAndRestorePage(),
    SettingsCategory.search => const SearchSettingsPage(),
    SettingsCategory.accessibility => const AccessibilityPage(),
    SettingsCategory.viewer => const ImageViewerPage(),
    SettingsCategory.privacy => const PrivacyPage(),
    SettingsCategory.developerOptions => const DeveloperOptionsPage(),
    SettingsCategory.appLock => const AppLockSettingsPage(),
    SettingsCategory.auth ||
    SettingsCategory.listing ||
    SettingsCategory.gestures ||
    SettingsCategory.network => throw StateError(
      '${category.id} has no app settings page',
    ),
  },
);
