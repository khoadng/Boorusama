// Package imports:
import 'package:i18n/i18n.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../configs/config/data.dart';
import '../../../configs/config/types.dart';
import '../../../posts/listing/types.dart';
import '../../types.dart';
import '../generated/settings_index.g.dart';

SettingsEnvironment settingsEnvironment({
  required Settings settings,
  required bool mobileDownloadPolicy,
  required bool hasPremium,
  required bool showPremium,
  required bool incognitoKeyboardAvailable,
  BooruConfig? profile,
  BooruConfigData? draft,
}) {
  final profileData = draft ?? profile?.toBooruConfigData();
  final listing = profileData?.listingTyped;
  final viewer = profileData?.viewerTyped;
  final location = profileData?.customDownloadLocation;
  return SettingsEnvironment(
    hasProfile: profile != null,
    mobileDownloadPolicy: mobileDownloadPolicy,
    hasPremium: hasPremium,
    showPremium: showPremium,
    incognitoKeyboardAvailable: incognitoKeyboardAvailable,
    appLockIsPin: settings.appLockType.isPin,
    appLockEnabled: settings.appLockType.appLockEnabled,
    appListingPaginated: settings.listing.pageMode == PageMode.paginated,
    profileListingPaginated:
        (listing?.settings.pageMode ??
            ListingConfigs.undefined().settings.pageMode) ==
        PageMode.paginated,
    profileListingEnabled: listing?.enable ?? false,
    profileViewerEnabled: viewer?.enable ?? false,
    customDownloadFolder: location != null && location.isNotEmpty,
    booruId: profile?.auth.booruType.id,
  );
}

List<SettingsSearchEntry> buildSettingsSearchCatalog(
  BuildContext context, {
  required Settings settings,
  required bool mobileDownloadPolicy,
  required bool hasPremium,
  required bool showPremium,
  required bool incognitoKeyboardAvailable,
  BooruConfig? profile,
  BooruConfigData? draft,
}) {
  final environment = settingsEnvironment(
    settings: settings,
    mobileDownloadPolicy: mobileDownloadPolicy,
    hasPremium: hasPremium,
    showPremium: showPremium,
    incognitoKeyboardAvailable: incognitoKeyboardAvailable,
    profile: profile,
    draft: draft,
  );
  final profileLabel = profile == null
      ? ''
      : (draft?.name ?? profile.name).isNotEmpty
      ? (draft?.name ?? profile.name)
      : Uri.parse(profile.url).host;
  return resolveSettingsCatalog(
    context.t,
    environment,
    profileLabel: profileLabel,
  );
}

/// Resolve generated metadata without constructing pages or changing the locale.
List<SettingsSearchEntry> resolveSettingsCatalog(
  Translations translations,
  SettingsEnvironment environment, {
  required String profileLabel,
}) {
  final english = Translations();
  final result = <SettingsSearchEntry>[];
  for (final scope in SettingsSearchScope.values) {
    final owner = scope == SettingsSearchScope.app
        ? translations.settings.app_settings
        : profileLabel;
    for (final definition in SettingsIndex.forScope(scope)) {
      for (final placement in definition.placements) {
        if (placement.scope != scope ||
            !placement.searchable ||
            !placement.isAvailable(environment)) {
          continue;
        }
        final section = definition.section?.call(translations);
        result.add(
          SettingsSearchEntry(
            id: '${scope.name}:${definition.id}',
            title: definition.label(translations),
            breadcrumb:
                '$owner › ${placement.category.breadcrumbLabel(translations, scope)}${section == null ? '' : ' › $section'}',
            scope: scope,
            category: placement.category,
            target: definition.id,
            description: definition.description?.call(translations) ?? '',
            keywords: [
              definition.keywords,
              definition.label(english),
              definition.description?.call(english),
              definition.optionTerms?.call(translations),
              definition.optionTerms?.call(english),
              definition.section?.call(english),
              placement.category.breadcrumbLabel(english, scope),
            ].whereType<String>().join(' '),
            status: placement.status?.call(
              translations,
              environment,
              profileLabel,
            ),
          ),
        );
      }
    }
  }
  for (final page in SettingsIndex.pages) {
    if (!page.category.isAvailable(environment, page.scope)) continue;
    result.add(
      SettingsSearchEntry(
        id: '${page.scope.name}:page:${page.category.id}',
        title: page.category.label(translations, page.scope),
        breadcrumb: page.scope == SettingsSearchScope.app
            ? translations.settings.app_settings
            : profileLabel,
        scope: page.scope,
        category: page.category,
        keywords:
            '${page.keywords} ${page.category.label(english, page.scope)}',
      ),
    );
  }
  return result;
}
