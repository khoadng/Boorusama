// Package imports:
import 'package:i18n/i18n.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../generated/settings_category.g.dart';
import '../generated/settings_environment.g.dart';

class SettingDefinition {
  const SettingDefinition({
    required this.id,
    required this.label,
    required this.placements,
    this.keywords = '',
    this.description,
    this.optionTerms,
    this.section,
  });
  final String id;
  final String Function(Translations) label;
  final List<SettingPlacement> placements;
  final String keywords;
  final String Function(Translations)? description;
  final String Function(Translations)? optionTerms;
  final String Function(Translations)? section;

  String title(BuildContext context) => label(context.t);

  bool isAvailable(
    SettingsEnvironment environment,
    SettingsSearchScope scope,
  ) => placements.any(
    (placement) =>
        placement.scope == scope && placement.isAvailable(environment),
  );
}

class SettingPlacement {
  const SettingPlacement({
    required this.scope,
    required this.category,
    this.available,
    this.searchable = true,
    this.status,
  });
  final SettingsSearchScope scope;
  final SettingsCategory category;
  final bool Function(SettingsEnvironment)? available;
  final bool searchable;
  final String? Function(
    Translations,
    SettingsEnvironment,
    String profileLabel,
  )?
  status;

  bool isAvailable(SettingsEnvironment environment) =>
      category.isAvailable(environment, scope) &&
      (available?.call(environment) ?? true);
}

class SettingPageDefinition {
  const SettingPageDefinition({
    required this.scope,
    required this.category,
    required this.keywords,
  });
  final SettingsSearchScope scope;
  final SettingsCategory category;
  final String keywords;
}

class SettingsSearchEntry {
  const SettingsSearchEntry({
    required this.id,
    required this.title,
    required this.breadcrumb,
    required this.scope,
    required this.category,
    this.target,
    this.description = '',
    this.keywords = '',
    this.status,
  });
  final String id;
  final String title;
  final String breadcrumb;
  final SettingsSearchScope scope;
  final SettingsCategory category;
  final String? target;
  final String description;
  final String keywords;
  final String? status;
}
