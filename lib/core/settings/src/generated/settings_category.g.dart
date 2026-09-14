// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: settings.yaml; regenerate with boorusama settings gen.

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'settings_environment.g.dart';

enum SettingsSearchScope { app, profile }

enum SettingsCategory {
  appearance(
    'appearance',
    FontAwesomeIcons.paintRoller,
    app: const _Destination(
      label: _appearanceAppTitle,
      target: '/settings/appearance',
    ),
    profile: const _Destination(
      label: _appearanceProfileTitle,
      target: 'appearance',
      available: _condition_hasProfile_showPremium,
    ),
    keywords: 'theme colors dark light layout',
  ),
  language(
    'language',
    FontAwesomeIcons.language,
    app: const _Destination(
      label: _languageAppTitle,
      target: '/settings/language',
    ),
    keywords: 'translation locale language',
  ),
  download(
    'download',
    FontAwesomeIcons.download,
    app: const _Destination(
      label: _downloadAppTitle,
      target: '/settings/download',
    ),
    profile: const _Destination(
      label: _downloadProfileTitle,
      target: 'download',
      available: _condition_hasProfile,
    ),
  ),
  dataAndStorage(
    'data_and_storage',
    FontAwesomeIcons.database,
    app: const _Destination(
      label: _dataAndStorageAppTitle,
      target: '/settings/data_and_storage',
    ),
  ),
  backupAndRestore(
    'backup_and_restore',
    FontAwesomeIcons.cloudArrowDown,
    app: const _Destination(
      label: _backupAndRestoreAppTitle,
      target: '/settings/backup_and_restore',
    ),
    keywords: 'backup restore export import transfer',
  ),
  search(
    'search',
    FontAwesomeIcons.magnifyingGlass,
    app: const _Destination(label: _searchAppTitle, target: '/settings/search'),
    profile: const _Destination(
      label: _searchProfileTitle,
      target: 'search',
      available: _condition_hasProfile,
    ),
  ),
  accessibility(
    'accessibility',
    FontAwesomeIcons.universalAccess,
    app: const _Destination(
      label: _accessibilityAppTitle,
      target: '/settings/accessibility',
    ),
  ),
  viewer(
    'viewer',
    FontAwesomeIcons.image,
    app: const _Destination(
      label: _viewerAppTitle,
      target: '/settings/image_viewer',
    ),
    profile: const _Destination(
      label: _viewerAppTitle,
      target: 'viewer',
      available: _condition_hasProfile,
    ),
  ),
  privacy(
    'privacy',
    FontAwesomeIcons.shieldHalved,
    app: const _Destination(
      label: _privacyAppTitle,
      target: '/settings/privacy',
    ),
  ),
  developerOptions(
    'developer_options',
    FontAwesomeIcons.code,
    app: const _Destination(
      label: _developerOptionsAppTitle,
      target: '/settings/developer_options',
      pageEntry: false,
    ),
  ),
  appLock(
    'app_lock',
    Symbols.lock,
    app: const _Destination(
      label: _appLockAppTitle,
      target: '/settings/privacy/app_lock',
      parent: SettingsCategory.privacy,
      pageEntry: false,
    ),
  ),
  auth(
    'auth',
    Symbols.key,
    profile: const _Destination(
      label: _authProfileTitle,
      target: 'auth',
      available: _condition_hasProfile2,
    ),
    keywords:
        'login account authentication api key password cookies credentials',
  ),
  listing(
    'listing',
    Symbols.grid_view,
    profile: const _Destination(
      label: _listingProfileTitle,
      target: 'listing',
      available: _condition_hasProfile,
    ),
  ),
  gestures(
    'gestures',
    Symbols.swipe,
    profile: const _Destination(
      label: _gesturesProfileTitle,
      target: 'gestures',
      available: _condition_hasProfile,
    ),
  ),
  network(
    'network',
    Symbols.language,
    profile: const _Destination(
      label: _networkProfileTitle,
      target: 'network',
      available: _condition_hasProfile,
    ),
  );

  const SettingsCategory(
    this.id,
    this.icon, {
    _Destination? app,
    _Destination? profile,
    this.keywords = '',
  }) : _app = app,
       _profile = profile;

  final String id;

  final Object icon;

  final String keywords;

  final _Destination? _app;

  final _Destination? _profile;

  static const appMenu = [
    appearance,
    language,
    download,
    dataAndStorage,
    backupAndRestore,
    search,
    accessibility,
    viewer,
    privacy,
  ];

  static const profileMenu = [
    auth,
    listing,
    appearance,
    download,
    search,
    gestures,
    viewer,
    network,
  ];

  _Destination? _destination(SettingsSearchScope scope) => switch (scope) {
    SettingsSearchScope.app => _app,
    SettingsSearchScope.profile => _profile,
  };

  _Destination _requireDestination(SettingsSearchScope scope) =>
      _destination(scope) ??
      (throw ArgumentError.value(
        scope,
        'scope',
        'Unsupported category scope for $id',
      ));

  String label(Translations t, SettingsSearchScope scope) =>
      _requireDestination(scope).label(t);

  String title(BuildContext context, SettingsSearchScope scope) =>
      label(context.t, scope);

  String breadcrumbLabel(Translations t, SettingsSearchScope scope) {
    final destination = _requireDestination(scope);
    final own = destination.label(t);
    final parent = destination.parent;
    return parent == null ? own : '${parent.breadcrumbLabel(t, scope)} › $own';
  }

  String breadcrumbTitle(BuildContext context, SettingsSearchScope scope) =>
      breadcrumbLabel(context.t, scope);

  bool isAvailable(SettingsEnvironment env, SettingsSearchScope scope) {
    final destination = _destination(scope);
    return destination != null && (destination.available?.call(env) ?? true);
  }

  String get appRoute =>
      _app?.target ?? (throw StateError('Category has no app destination'));

  String get profileTab =>
      _profile?.target ??
      (throw StateError('Category has no profile destination'));

  static Iterable<SettingsCategory> pagesForScope(SettingsSearchScope scope) {
    final menu = switch (scope) {
      SettingsSearchScope.app => appMenu,
      SettingsSearchScope.profile => profileMenu,
    };
    return [
      ...menu,
      ...values.where((category) => !menu.contains(category)),
    ].where((category) => category._destination(scope)?.pageEntry ?? false);
  }
}

class _Destination {
  const _Destination({
    required this.label,
    required this.target,
    this.parent,
    this.available,
    this.pageEntry = true,
  });

  final String Function(Translations) label;

  final String target;

  final SettingsCategory? parent;

  final bool Function(SettingsEnvironment)? available;

  final bool pageEntry;
}

String _appearanceAppTitle(Translations t) => t.settings.appearance.appearance;
String _appearanceProfileTitle(Translations t) => t.booru.appearance.title;
bool _condition_hasProfile_showPremium(SettingsEnvironment env) =>
    env.hasProfile && env.showPremium;
String _languageAppTitle(Translations t) => t.settings.language.language;
String _downloadAppTitle(Translations t) => t.settings.download.title;
String _downloadProfileTitle(Translations t) => t.booru.downloads.title;
bool _condition_hasProfile(SettingsEnvironment env) => env.hasProfile;
String _dataAndStorageAppTitle(Translations t) =>
    t.settings.data_and_storage.data_and_storage;
String _backupAndRestoreAppTitle(Translations t) =>
    t.settings.backup_and_restore.backup_and_restore;
String _searchAppTitle(Translations t) => t.settings.search.search;
String _searchProfileTitle(Translations t) => t.booru.search.title;
String _accessibilityAppTitle(Translations t) =>
    t.settings.accessibility.accessibility;
String _viewerAppTitle(Translations t) => t.settings.image_viewer.image_viewer;
String _privacyAppTitle(Translations t) => t.settings.privacy.privacy;
String _developerOptionsAppTitle(Translations t) => 'Developer options';
String _appLockAppTitle(Translations t) => t.settings.privacy.app_lock.title;
String _authProfileTitle(Translations t) => t.booru.authentication.title;
bool _condition_hasProfile2(SettingsEnvironment env) =>
    env.hasProfile &&
    const {
      20,
      21,
      23,
      24,
      25,
      27,
      28,
      29,
      30,
      31,
      32,
      34,
    }.contains(env.booruId);
String _listingProfileTitle(Translations t) => t.booru.listing.title;
String _gesturesProfileTitle(Translations t) => t.booru.gestures.title;
String _networkProfileTitle(Translations t) => t.booru.network.title;
