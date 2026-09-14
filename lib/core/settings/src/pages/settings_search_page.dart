// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../foundation/platform.dart';
import '../../../boorus/engine/providers.dart';
import '../../../configs/config/data.dart';
import '../../../configs/config/providers.dart';
import '../../../configs/config/types.dart';
import '../../../configs/create/create.dart';
import '../../../configs/create/providers.dart';
import '../../../configs/create/src/pages/unsaved_alert_dialog.dart';
import '../../../configs/manage/providers.dart';
import '../../../premiums/providers.dart';
import '../../../tracking/providers.dart';
import '../data/settings_search_catalog.dart';
import '../generated/settings_category.g.dart';
import '../providers/settings_provider.dart';
import '../routes/settings_page_route.dart';
import '../types/settings_search_entry.dart';
import '../widgets/setting_anchor.dart';
import '../widgets/settings_page_scaffold.dart';
import '../widgets/settings_search_view.dart';
import 'settings_categories.dart';

class SettingsSearchPage extends ConsumerStatefulWidget {
  const SettingsSearchPage({
    this.editingProfile,
    this.editingId,
    this.onOpenProfile,
    this.initialEntry,
    this.navigationBuilder,
    super.key,
  });

  final SettingEntry? initialEntry;
  final Widget Function(
    BuildContext context,
    SettingEntry? selected,
    Future<void> Function(SettingEntry) select,
    VoidCallback? editProfile,
  )?
  navigationBuilder;
  final BooruConfig? editingProfile;
  final EditBooruConfigId? editingId;
  final void Function(SettingsSearchEntry)? onOpenProfile;

  @override
  ConsumerState<SettingsSearchPage> createState() => _SettingsSearchPageState();
}

class _SettingsSearchPageState extends ConsumerState<SettingsSearchPage> {
  SettingsSearchEntry? _preview;
  var _previewRequest = 0;
  late SettingEntry? _entry = widget.initialEntry;
  BooruConfig? _profilePreview;

  @override
  void didUpdateWidget(covariant SettingsSearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialEntry != oldWidget.initialEntry &&
        _entry?.id == oldWidget.initialEntry?.id) {
      _entry = widget.initialEntry;
    }
  }

  Future<bool> _leaveProfile() async {
    final profile = _profilePreview;
    if (profile == null) return true;
    final id = EditBooruConfigId.fromConfig(profile);
    final data = ref.read(editBooruConfigProvider(id));
    if (data == profile.toBooruConfigData()) return true;
    var confirmed = false;
    await showDialog<void>(
      context: context,
      builder: (_) => UnsavedAlertDialog(
        onSave: () {
          ref
              .read(booruConfigProvider.notifier)
              .addOrUpdate(id: id, newConfig: data);
          confirmed = true;
        },
        onDiscard: () => confirmed = true,
      ),
    );
    return confirmed;
  }

  Future<void> _selectEntry(SettingEntry entry) async {
    if (!await _leaveProfile() || !mounted) return;
    setState(() {
      _entry = entry;
      _preview = null;
      _profilePreview = null;
    });
  }

  Widget _appDestination(SettingsSearchEntry result, {required bool dense}) {
    final categories = settingsCategories(context, showDeveloperOptions: false);
    final entry = settingsCategoryEntry(context, result.category);
    final options = SettingsPageOptions(
      showIcon: !dense,
      dense: dense,
      entries: categories,
    );
    void openNested(BuildContext context, SettingEntry entry) {
      if (dense) {
        _selectEntry(entry);
        return;
      }
      pushSettingsPage(
        context,
        name: entry.name,
        builder: (_) => SettingsPageNavigationScope(
          openContent: openNested,
          child: SettingsPageScope(
            options: SettingsPageOptions(
              showIcon: true,
              dense: false,
              entries: categories,
            ),
            child: entry.content,
          ),
        ),
      );
    }

    return SettingsPageNavigationScope(
      openContent: openNested,
      child: SettingsPageScope(
        options: options,
        child: SettingReveal(
          key: ValueKey(result.id),
          target: result.target,
          request: _previewRequest,
          child: entry.content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasProfiles = ref.watch(hasBooruConfigsProvider);
    final profile =
        widget.editingProfile ??
        _profilePreview ??
        (hasProfiles ? ref.watchConfig : null);
    final editingId =
        widget.editingId ??
        (_profilePreview == null
            ? null
            : EditBooruConfigId.fromConfig(_profilePreview!));
    final draft = editingId == null
        ? null
        : ref.watch(editBooruConfigProvider(editingId));
    final builder = profile == null
        ? null
        : ref.watch(booruBuilderProvider(profile.auth));
    if (profile != null && builder == null) {
      throw StateError(
        'No settings editor is registered for ${profile.auth.booruType}.',
      );
    }
    final entries = buildSettingsSearchCatalog(
      context,
      settings: ref.watch(settingsProvider),
      mobileDownloadPolicy: ref.watch(appPlatformProvider).isMobile,
      hasPremium: ref.watch(hasPremiumProvider),
      showPremium: ref.watch(showPremiumFeatsProvider),
      incognitoKeyboardAvailable: ref.watch(trackerProvider).hasValue,
      profile: profile,
      draft: draft,
    );
    return PopScope(
      canPop: _profilePreview == null,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !await _leaveProfile() || !context.mounted) return;
        setState(() {
          _profilePreview = null;
          _preview = null;
        });
        Navigator.of(context).pop();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 700;
          return SettingsSearchView(
            entries: entries,
            activeEntryId: wide ? _preview?.id : null,
            autofocus: widget.navigationBuilder == null,
            navigation: widget.navigationBuilder?.call(
              context,
              _entry,
              _selectEntry,
              profile == null
                  ? null
                  : () {
                      final result = entries.firstWhere(
                        (e) => e.scope == SettingsSearchScope.profile,
                      );
                      setState(() {
                        _profilePreview = profile;
                        _preview = result;
                        _previewRequest++;
                      });
                    },
            ),
            onClose: () => Navigator.of(context).maybePop(),
            detail: wide
                ? _profilePreview != null && _preview != null
                      ? Navigator(
                          pages: [
                            const _InlineSettingsPage(
                              key: ValueKey('settings-editor-base'),
                              child: SizedBox.shrink(),
                            ),
                            _InlineSettingsPage(
                              key: ValueKey(_profilePreview!.id),
                              child: SettingReveal(
                                target: _preview!.target,
                                request: _previewRequest,
                                child: builder!.updateConfigPageBuilder(
                                  context,
                                  EditBooruConfigId.fromConfig(
                                    _profilePreview!,
                                  ),
                                  initialTab: _preview!.category.profileTab,
                                ),
                              ),
                            ),
                          ],
                          onDidRemovePage: (_) {
                            if (mounted) {
                              setState(() {
                                _profilePreview = null;
                                _preview = null;
                              });
                            }
                          },
                        )
                      : _preview != null
                      ? _appDestination(_preview!, dense: true)
                      : _entry != null
                      ? SettingsPageNavigationScope(
                          openContent: (_, entry) => _selectEntry(entry),
                          child: SettingsPageScope(
                            options: SettingsPageOptions(
                              showIcon: false,
                              dense: true,
                              entries: settingsCategories(
                                context,
                                showDeveloperOptions: false,
                              ),
                            ),
                            child: _entry!.content,
                          ),
                        )
                      : Center(
                          child: Text(context.t.settings_search.select_setting),
                        )
                : null,
            onOpen: (result) async {
              if (result.scope == SettingsSearchScope.profile) {
                if (widget.onOpenProfile case final open?) {
                  if (wide) {
                    setState(() {
                      _preview = null;
                      _profilePreview = null;
                      _entry = widget.initialEntry;
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
                  open(result);
                  return;
                }
                if (builder == null || profile == null) {
                  throw StateError(
                    'The selected profile has no settings editor.',
                  );
                }
                if (wide) {
                  setState(() {
                    _profilePreview = profile;
                    _preview = result;
                    _previewRequest++;
                  });
                  return;
                }
                await pushSettingsPage(
                  context,
                  name: '/boorus/${profile.id}/update',
                  builder: (context) => SettingReveal(
                    target: result.target,
                    child: builder.updateConfigPageBuilder(
                      context,
                      EditBooruConfigId.fromConfig(profile),
                      initialTab: result.category.id,
                    ),
                  ),
                );
              } else if (wide) {
                if (!await _leaveProfile() || !mounted) return;
                setState(() {
                  _profilePreview = null;
                  _entry = settingsCategoryEntry(context, result.category);
                  _preview = result;
                  _previewRequest++;
                });
              } else {
                await pushSettingsPage(
                  context,
                  name: result.category.appRoute,
                  builder: (_) => _appDestination(result, dense: false),
                );
              }
            },
          );
        },
      ),
    );
  }
}

/// A contained editor route keeps save/back actions inside the detail pane.
class _InlineSettingsPage extends Page<void> {
  const _InlineSettingsPage({required this.child, super.key});
  final Widget child;
  @override
  Route<void> createRoute(BuildContext context) {
    late final PageRouteBuilder<void> route;
    return route = PageRouteBuilder<void>(
      settings: this,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, _, _) => (route.settings as _InlineSettingsPage).child,
    );
  }
}
