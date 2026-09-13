import 'package:yaml/yaml.dart';

import 'model.dart';

/// A validated, ordered schema. YAML order determines stable search tie-breaking.
final class SettingsCatalog {
  SettingsCatalog._(
    List<String> facts,
    Map<String, Map<String, dynamic>> categories,
    Map<String, Map<String, dynamic>> settings,
  ) : facts = List.unmodifiable(facts),
      categories = Map.unmodifiable({
        for (final e in categories.entries) e.key: CatalogCategory(e.value),
      }),
      settings = Map.unmodifiable({
        for (final e in settings.entries)
          e.key: CatalogSetting(
            e.key.split('.').first,
            e.key.split('.').last,
            e.value,
          ),
      });
  final List<String> facts;
  final Map<String, CatalogCategory> categories;
  final Map<String, CatalogSetting> settings;

  static SettingsCatalog parse(
    String source, {
    required Map<String, dynamic> translations,
    required Map<String, Set<String>> icons,
    required Map<String, int> boorus,
    String path = 'settings.yaml',
  }) {
    final document = loadYaml(source, sourceUrl: Uri.file(path));
    Never fail(String location, String message) {
      throw FormatException('$path: $location: $message');
    }

    Map<String, dynamic> map(Object? value, String location) {
      if (value is! Map || value.keys.any((key) => key is! String)) {
        fail(location, 'Expected a mapping with string keys');
      }
      return Map<String, dynamic>.from(value);
    }

    void keys(
      Map<String, dynamic> value,
      Set<String> allowed,
      String location,
    ) {
      for (final key in value.keys) {
        if (!allowed.contains(key)) fail('$location.$key', 'Unknown field');
      }
    }

    String string(Object? value, String location) {
      if (value is! String || value.trim().isEmpty) {
        fail(location, 'Expected nonempty text');
      }
      return value;
    }

    void identifier(
      String value,
      String location, {
      Set<String> reserved = const {},
    }) {
      if (!RegExp(r'^[a-z][a-zA-Z0-9]*$').hasMatch(value) ||
          const {
            'assert',
            'break',
            'case',
            'catch',
            'const',
            'continue',
            'do',
            'else',
            'extends',
            'false',
            'final',
            'finally',
            'for',
            'if',
            'in',
            'is',
            'new',
            'null',
            'rethrow',
            'return',
            'super',
            'this',
            'throw',
            'true',
            'try',
            'var',
            'void',
            'while',
            'with',
            'await',
            'yield',
            'runtimeType',
            'hashCode',
            'toString',
            'noSuchMethod',
            'class',
            'enum',
            'switch',
            'default',
          }.contains(value) ||
          reserved.contains(value)) {
        fail(location, 'Invalid or reserved Dart identifier: $value');
      }
    }

    List<String> strings(Object? value, String location) {
      if (value is! List) fail(location, 'Expected a list');
      return [for (final item in value) string(item, location)];
    }

    Set<String> placeholders(String text) => RegExp(
      r'\$(?:\{(\w+)\}|(\w+))',
    ).allMatches(text).map((m) => m[1] ?? m[2]!).toSet();
    void text(
      Object? value,
      String location, {
      Set<String> arguments = const {},
    }) {
      if (value is Map) {
        final literal = map(value, location);
        keys(literal, {'literal'}, location);
        string(literal['literal'], location);
        if (arguments.isNotEmpty) {
          fail(location, 'Literal labels cannot have arguments');
        }
        return;
      }
      final key = string(value, location);
      dynamic node = translations;
      for (final segment in key.split('.')) {
        if (node is! Map || !node.containsKey(segment)) {
          fail(location, 'Unknown translation key: $key');
        }
        node = node[segment];
      }
      if (node is! String) {
        fail(location, 'Translation must be a string leaf: $key');
      }
      final required = placeholders(node);
      if (required.length != arguments.length ||
          !required.containsAll(arguments)) {
        fail(
          location,
          'Translation $key requires arguments $required, got $arguments',
        );
      }
    }

    final root = map(document, 'root');
    keys(root, {'version', 'facts', 'menus', 'categories', 'groups'}, 'root');
    if (root['version'] != 1) fail('version', 'Expected schema version 1');
    final facts = strings(root['facts'], 'facts');
    if (facts.toSet().length != facts.length) fail('facts', 'Duplicate fact');
    if (!facts.contains('hasProfile')) {
      fail('facts', 'hasProfile is required for profile scope');
    }
    for (final fact in facts) {
      identifier(fact, 'facts', reserved: {'booruId'});
    }
    void applicability(
      Map<String, dynamic> binding,
      String scope,
      String location,
    ) {
      if (!binding.containsKey('boorus')) return;
      final value = binding['boorus'];
      if (scope != 'profile') {
        fail(location, 'boorus is only valid in profile scope');
      }
      if (value is! List || value.isEmpty) {
        fail(location, 'Expected a non-empty boorus list');
      }
      final ids = <int>[];
      for (final name in value) {
        final id = name is String ? boorus[name] : null;
        if (id == null) fail(location, 'Unknown booru: $name');
        if (ids.contains(id)) fail(location, 'Duplicate booru: $name');
        ids.add(id);
      }
      binding['boorus'] = ids..sort();
    }

    void condition(Object? value, String location) {
      if (value == null) return;
      final conditions = map(value, location);
      for (final entry in conditions.entries) {
        if (!facts.contains(entry.key)) {
          fail(location, 'Unknown fact: ${entry.key}');
        }
        if (entry.value is! bool) {
          fail(location, 'Fact conditions must be booleans');
        }
      }
    }

    void boolean(Map<String, dynamic> data, String key, String location) {
      if (data.containsKey(key) && data[key] is! bool) {
        fail('$location.$key', 'Expected a boolean');
      }
    }

    final menus = map(root['menus'], 'menus');
    keys(menus, {'app', 'profile'}, 'menus');
    for (final scope in ['app', 'profile']) {
      final names = strings(menus[scope], 'menus.$scope');
      if (names.toSet().length != names.length) {
        fail('menus.$scope', 'Duplicate menu category');
      }
      menus[scope] = names;
    }
    final categories = <String, Map<String, dynamic>>{};
    final categoryIds = <String>{};
    final destinations = <String>{};
    for (final entry in map(root['categories'], 'categories').entries) {
      final location = 'categories.${entry.key}';
      identifier(
        entry.key,
        location,
        reserved: {
          'values',
          'index',
          'name',
          'id',
          'label',
          'title',
          'icon',
          'appRoute',
          'profileTab',
          'appMenu',
          'profileMenu',
          'isAvailable',
          'breadcrumbTitle',
          'breadcrumbLabel',
          'keywords',
          'pagesForScope',
        },
      );
      final category = map(entry.value, location);
      keys(category, {'icon', 'app', 'profile', 'keywords'}, location);
      final id = entry.key.replaceAllMapped(
        RegExp('[A-Z]'),
        (m) => '_${m[0]!.toLowerCase()}',
      );
      category['id'] = id;
      if (!categoryIds.add(id)) fail(location, 'Duplicate category ID: $id');
      final icon = map(category['icon'], '$location.icon');
      keys(icon, {'family', 'name'}, '$location.icon');
      if (!(icons[icon['family']]?.contains(icon['name']) ?? false)) {
        fail('$location.icon', 'Unknown icon: $icon');
      }
      category['icon'] = icon;
      if (!category.containsKey('app') && !category.containsKey('profile')) {
        fail(location, 'Category needs a destination');
      }
      for (final scope in ['app', 'profile']) {
        if (!category.containsKey(scope)) continue;
        final binding = map(category[scope], '$location.$scope');
        keys(binding, {
          'title',
          if (scope == 'app') 'route' else 'tab',
          'when',
          'boorus',
          'parent',
          'pageEntry',
        }, '$location.$scope');
        text(binding['title'], '$location.$scope.title');
        final target = string(
          binding[scope == 'app' ? 'route' : 'tab'],
          '$location.$scope.destination',
        );
        if (scope == 'app' && !target.startsWith('/settings/')) {
          fail(location, 'App routes must start with /settings/');
        }
        if (scope == 'profile' &&
            !RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(target)) {
          fail(location, 'Invalid profile tab');
        }
        if (!destinations.add('$scope:$target')) {
          fail(location, 'Duplicate destination $target');
        }
        applicability(binding, scope, '$location.$scope.boorus');
        condition(binding['when'], '$location.$scope.when');
        if (scope == 'profile') {
          final conditions = map(
            binding['when'] ?? <String, dynamic>{},
            '$location.$scope.when',
          );
          if (conditions['hasProfile'] == false) {
            fail(
              '$location.$scope.when',
              'Profile scope requires hasProfile: true',
            );
          }
          binding['when'] = {...conditions, 'hasProfile': true};
        }
        final menu = menus[scope] as List<String>;
        binding['menu'] = menu.contains(entry.key);
        binding['order'] = menu.contains(entry.key)
            ? menu.indexOf(entry.key)
            : menu.length;
        boolean(binding, 'pageEntry', location);
        category[scope] = binding;
      }
      if (category['keywords'] != null) {
        strings(category['keywords'], '$location.keywords');
      }
      categories[entry.key] = category;
    }
    for (final scope in ['app', 'profile']) {
      for (final name in menus[scope] as List<String>) {
        if (categories[name]?[scope] == null) {
          fail('menus.$scope', 'Unknown category or unsupported scope: $name');
        }
      }
      for (final entry in categories.entries) {
        final binding = entry.value[scope] as Map<String, dynamic>?;
        if (binding == null) continue;
        final seen = <String>{entry.key};
        dynamic parent = binding['parent'];
        while (parent != null) {
          if (parent is! String || categories[parent]?[scope] == null) {
            fail(
              'categories.${entry.key}.$scope.parent',
              'Unknown parent in this scope: $parent',
            );
          }
          if (!seen.add(parent)) {
            fail(
              'categories.${entry.key}.$scope.parent',
              'Category parent cycle',
            );
          }
          parent = (categories[parent]![scope] as Map)['parent'];
        }
      }
    }
    Map<String, dynamic> placement(
      Object? raw,
      String scope,
      String location, {
      bool requireCategory = false,
      bool resolved = false,
    }) {
      final binding = map(raw, location);
      keys(binding, {
        'category',
        'boorus',
        'when',
        'searchable',
        'status',
      }, location);
      if ((requireCategory || binding.containsKey('category')) &&
          categories[binding['category']]?[scope] == null) {
        fail(
          location,
          'Unknown category or unsupported scope: ${binding['category']} / $scope',
        );
      }
      if (!resolved) applicability(binding, scope, '$location.boorus');
      condition(binding['when'], '$location.when');
      boolean(binding, 'searchable', location);
      if (binding['status'] != null) {
        if (binding['status'] is! List) {
          fail(location, 'Status must be a list');
        }
        var unconditional = false;
        final statuses = <Map<String, dynamic>>[];
        for (final raw in binding['status'] as List) {
          if (unconditional) {
            fail(
              location,
              'Status after an unconditional case is unreachable',
            );
          }
          final status = map(raw, '$location.status');
          keys(status, {'when', 'text', 'arguments'}, '$location.status');
          condition(status['when'], '$location.status.when');
          final args = map(
            status['arguments'] ?? <String, dynamic>{},
            '$location.status.arguments',
          );
          if (args.values.any((value) => value != 'profileLabel')) {
            fail(
              location,
              'Only profileLabel may be interpolated into status',
            );
          }
          text(
            status['text'],
            '$location.status.text',
            arguments: args.keys.toSet(),
          );
          unconditional =
              status['when'] == null || (status['when'] as Map).isEmpty;
          statuses.add({...status, 'arguments': args});
        }
        binding['status'] = statuses;
      }
      return binding;
    }

    final settings = <String, Map<String, dynamic>>{};
    final groups = map(root['groups'], 'groups');
    if (groups.isEmpty) fail('groups', 'Expected at least one group');
    for (final groupEntry in groups.entries) {
      final groupName = groupEntry.key;
      final groupLocation = 'groups.$groupName';
      identifier(
        groupName,
        groupLocation,
        reserved: {'all', 'pages', 'forScope'},
      );
      final group = map(groupEntry.value, groupLocation);
      keys(group, {'scopes', 'settings'}, groupLocation);
      final defaults = map(group['scopes'], '$groupLocation.scopes');
      keys(defaults, {'app', 'profile'}, '$groupLocation.scopes');
      for (final scope in defaults.keys.toList()) {
        defaults[scope] = placement(
          defaults[scope],
          scope,
          '$groupLocation.scopes.$scope',
          requireCategory: true,
        );
      }
      final members = map(group['settings'], '$groupLocation.settings');
      if (members.isEmpty) fail(groupLocation, 'Group needs settings');
      for (final entry in members.entries) {
        final location = '$groupLocation.settings.${entry.key}';
        identifier(entry.key, location);
        final setting = map(entry.value, location);
        keys(setting, {
          'title',
          'description',
          'section',
          'keywords',
          'optionLabels',
          'scopes',
        }, location);
        text(setting['title'], '$location.title');
        for (final field in ['description', 'section']) {
          if (setting[field] != null) text(setting[field], '$location.$field');
        }
        if (setting['keywords'] != null) {
          strings(setting['keywords'], '$location.keywords');
        }
        if (setting['optionLabels'] != null) {
          for (final label in strings(
            setting['optionLabels'],
            '$location.optionLabels',
          )) {
            text(label, '$location.optionLabels');
          }
        }
        final overrides = map(
          setting['scopes'] ?? <String, dynamic>{},
          '$location.scopes',
        );
        keys(overrides, {'app', 'profile'}, '$location.scopes');
        final scopes = <String, dynamic>{};
        for (final scope in {...defaults.keys, ...overrides.keys}) {
          final base = (defaults[scope] as Map<String, dynamic>?) ?? {};
          if (overrides[scope] == false) {
            if (!defaults.containsKey(scope)) {
              fail(
                '$location.scopes.$scope',
                'Cannot remove a scope that is not inherited',
              );
            }
            continue;
          }
          final own = overrides.containsKey(scope)
              ? placement(overrides[scope], scope, '$location.scopes.$scope')
              : <String, dynamic>{};
          final conditions = Map<String, dynamic>.from(
            base['when'] as Map? ?? {},
          );
          for (final fact in (own['when'] as Map? ?? {}).entries) {
            if (conditions.containsKey(fact.key) &&
                conditions[fact.key] != fact.value) {
              fail(
                '$location.scopes.$scope.when',
                'Contradictory inherited condition: ${fact.key}',
              );
            }
            conditions[fact.key as String] = fact.value;
          }
          final baseBoorus = base['boorus'] as List<int>?;
          final ownBoorus = own['boorus'] as List<int>?;
          final allowedBoorus = baseBoorus == null
              ? ownBoorus
              : ownBoorus == null
              ? baseBoorus
              : baseBoorus.where(ownBoorus.contains).toList();
          if (allowedBoorus != null && allowedBoorus.isEmpty) {
            fail(
              '$location.scopes.$scope.boorus',
              'No boorus match inherited applicability',
            );
          }
          final resolved = placement(
            {
              ...base,
              ...own,
              'boorus': ?allowedBoorus,
              'when': conditions,
            },
            scope,
            '$location.scopes.$scope',
            requireCategory: true,
            resolved: true,
          );
          final categoryBoorus =
              (categories[resolved['category']]![scope] as Map)['boorus']
                  as List<int>?;
          if (allowedBoorus != null &&
              categoryBoorus != null &&
              !allowedBoorus.any(categoryBoorus.contains)) {
            fail(
              '$location.scopes.$scope.boorus',
              'No boorus match category applicability',
            );
          }
          final categoryWhen =
              (categories[resolved['category']]![scope] as Map)['when']
                  as Map? ??
              {};
          for (final fact in categoryWhen.entries) {
            if (conditions.containsKey(fact.key) &&
                conditions[fact.key] != fact.value) {
              fail(
                '$location.scopes.$scope.when',
                'Contradictory category condition: ${fact.key}',
              );
            }
          }
          scopes[scope] = {
            ...resolved,
            'when': {...categoryWhen, ...conditions},
          };
        }
        if (scopes.isEmpty) fail(location, 'Setting needs a scope');
        setting['scopes'] = scopes;
        settings['$groupName.${entry.key}'] = setting;
      }
    }
    return SettingsCatalog._(facts, categories, settings);
  }
}
