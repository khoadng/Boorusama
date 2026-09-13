import 'dart:convert';

import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import 'catalog.dart';
import 'model.dart';

final class SettingsEmitter {
  SettingsEmitter(this.catalog);
  final SettingsCatalog catalog;
  final _dart = DartEmitter(useNullSafetySyntax: true);

  String _quote(String value) => literalString(value).accept(_dart).toString();
  Expression _expr(String value) => CodeExpression(Code(value));
  String _condition(Map<String, bool> conditions) {
    return conditions.isEmpty
        ? 'true'
        : (conditions.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
              .map((e) => '${e.value ? '' : '!'}env.${e.key}')
              .join(' && ');
  }

  String _label(
    CatalogLabel value, {
    String receiver = 't',
    Map<String, String>? arguments,
  }) {
    if (value.literal != null) return _quote(value.literal!);
    final key = value.key!;
    final args = arguments == null || arguments.isEmpty
        ? ''
        : '(${arguments.entries.map((e) => '${e.key}: ${e.value}').join(', ')})';
    return '$receiver.$key$args';
  }

  Parameter _param(String name, String type) => Parameter(
    (b) => b
      ..name = name
      ..type = refer(type),
  );
  Method _method(
    String name,
    String type,
    String expression, {
    List<Parameter> params = const [],
    bool getter = false,
  }) => Method(
    (b) => b
      ..name = name
      ..returns = refer(type)
      ..requiredParameters.addAll(params)
      ..type = getter ? MethodType.getter : null
      ..lambda = true
      ..body = Code(expression),
  );
  String _library(List<String> imports, List<Spec> body) {
    final library = Library(
      (b) => b
        ..directives.addAll(imports.map(Directive.import))
        ..body.addAll(body),
    );
    return '// GENERATED CODE - DO NOT MODIFY BY HAND.\n// Source: settings.yaml; regenerate with boorusama settings gen.\n\n${DartFormatter(languageVersion: DartFormatter.latestLanguageVersion).format(library.accept(_dart).toString())}';
  }

  Map<String, String> emit() => {
    'settings_environment.g.dart': _environment(),
    'settings_category.g.dart': _categories(),
    'settings_index.g.dart': _settings(),
  };

  String _environment() => _library([], [
    Class(
      (b) => b
        ..name = 'SettingsEnvironment'
        ..docs.add(
          '/// Runtime facts supplied by the app. No user-entered values are indexed.',
        )
        ..constructors.add(
          Constructor(
            (c) => c
              ..constant = true
              ..optionalParameters.addAll([
                Parameter(
                  (p) => p
                    ..name = 'booruId'
                    ..named = true
                    ..toThis = true,
                ),
                for (final fact in catalog.facts)
                  Parameter(
                    (p) => p
                      ..name = fact
                      ..named = true
                      ..required = true
                      ..toThis = true,
                  ),
              ]),
          ),
        )
        ..fields.addAll([
          _field('booruId', 'int?'),
          for (final fact in catalog.facts)
            Field(
              (f) => f
                ..name = fact
                ..type = refer('bool')
                ..modifier = FieldModifier.final$,
            ),
        ]),
    ),
  ]);

  String _categories() {
    final functions = _Functions();
    final categories = catalog.categories;
    Expression destination(
      String name,
      String scope,
      CatalogDestination data,
    ) => refer('_Destination').constInstance([], {
      'label': functions.use(
        '_$name${_upper(scope)}Title',
        'String',
        _label(data.title),
        [('t', 'Translations')],
      ),
      'target': literalString(data.target),
      if (data.parent != null)
        'parent': refer('SettingsCategory.${data.parent}'),
      if (data.condition.isNotEmpty || data.boorus.isNotEmpty)
        'available': _predicate(data.condition, functions, data.boorus),
      if (!data.pageEntry) 'pageEntry': literalFalse,
    });
    final category = Enum((b) {
      b
        ..name = 'SettingsCategory'
        ..values.addAll([
          for (final entry in categories.entries)
            EnumValue(
              (v) => v
                ..name = entry.key
                ..arguments.addAll([
                  literalString(entry.value.id),
                  refer('${entry.value.iconFamily}.${entry.value.iconName}'),
                ])
                ..namedArguments.addAll({
                  for (final binding in entry.value.scopes.entries)
                    binding.key: destination(
                      entry.key,
                      binding.key,
                      binding.value,
                    ),
                  if (entry.value.keywords.isNotEmpty)
                    'keywords': literalString(entry.value.keywords.join(' ')),
                }),
            ),
        ])
        ..constructors.add(
          Constructor(
            (c) => c
              ..constant = true
              ..requiredParameters.addAll([
                Parameter(
                  (p) => p
                    ..name = 'id'
                    ..toThis = true,
                ),
                Parameter(
                  (p) => p
                    ..name = 'icon'
                    ..toThis = true,
                ),
              ])
              ..optionalParameters.addAll([
                _named('app', '_Destination?'),
                _named('profile', '_Destination?'),
                Parameter(
                  (p) => p
                    ..name = 'keywords'
                    ..named = true
                    ..toThis = true
                    ..defaultTo = literalString('').code,
                ),
              ])
              ..initializers.addAll([
                const Code('_app = app'),
                const Code('_profile = profile'),
              ]),
          ),
        )
        ..fields.addAll([
          _field('id', 'String'),
          _field('icon', 'Object'),
          _field('keywords', 'String'),
          _field('_app', '_Destination?'),
          _field('_profile', '_Destination?'),
        ]);
      for (final scope in ['app', 'profile']) {
        final menu =
            categories.entries
                .where((e) => e.value.scopes[scope]?.menu ?? false)
                .toList()
              ..sort(
                (a, b) => a.value.scopes[scope]!.order.compareTo(
                  b.value.scopes[scope]!.order,
                ),
              );
        b.fields.add(
          Field(
            (f) => f
              ..name = '${scope}Menu'
              ..static = true
              ..modifier = FieldModifier.constant
              ..assignment = literalList([
                for (final entry in menu) refer(entry.key),
              ]).code,
          ),
        );
      }
      b.methods.addAll([
        _method(
          '_destination',
          '_Destination?',
          'switch (scope) { SettingsSearchScope.app => _app, SettingsSearchScope.profile => _profile }',
          params: [_param('scope', 'SettingsSearchScope')],
        ),
        _method(
          '_requireDestination',
          '_Destination',
          r"_destination(scope) ?? (throw ArgumentError.value(scope, 'scope', 'Unsupported category scope for $id'))",
          params: [_param('scope', 'SettingsSearchScope')],
        ),
        _method(
          'label',
          'String',
          '_requireDestination(scope).label(t)',
          params: [
            _param('t', 'Translations'),
            _param('scope', 'SettingsSearchScope'),
          ],
        ),
        _method(
          'title',
          'String',
          'label(context.t, scope)',
          params: [
            _param('context', 'BuildContext'),
            _param('scope', 'SettingsSearchScope'),
          ],
        ),
        Method(
          (m) => m
            ..name = 'breadcrumbLabel'
            ..returns = refer('String')
            ..requiredParameters.addAll([
              _param('t', 'Translations'),
              _param('scope', 'SettingsSearchScope'),
            ])
            ..body = const Code(
              r"final destination = _requireDestination(scope); final own = destination.label(t); final parent = destination.parent; return parent == null ? own : '${parent.breadcrumbLabel(t, scope)} › $own';",
            ),
        ),
        _method(
          'breadcrumbTitle',
          'String',
          'breadcrumbLabel(context.t, scope)',
          params: [
            _param('context', 'BuildContext'),
            _param('scope', 'SettingsSearchScope'),
          ],
        ),
        Method(
          (m) => m
            ..name = 'isAvailable'
            ..returns = refer('bool')
            ..requiredParameters.addAll([
              _param('env', 'SettingsEnvironment'),
              _param('scope', 'SettingsSearchScope'),
            ])
            ..body = const Code(
              'final destination = _destination(scope); return destination != null && (destination.available?.call(env) ?? true);',
            ),
        ),
        _method(
          'appRoute',
          'String',
          "_app?.target ?? (throw StateError('Category has no app destination'))",
          getter: true,
        ),
        _method(
          'profileTab',
          'String',
          "_profile?.target ?? (throw StateError('Category has no profile destination'))",
          getter: true,
        ),
        Method(
          (m) => m
            ..name = 'pagesForScope'
            ..static = true
            ..returns = refer('Iterable<SettingsCategory>')
            ..requiredParameters.add(_param('scope', 'SettingsSearchScope'))
            ..body = const Code(
              'final menu = switch (scope) {SettingsSearchScope.app => appMenu, SettingsSearchScope.profile => profileMenu}; return [...menu, ...values.where((category) => !menu.contains(category))].where((category) => category._destination(scope)?.pageEntry ?? false);',
            ),
        ),
      ]);
    });
    return _library(
      [
        'package:font_awesome_flutter/font_awesome_flutter.dart',
        'package:i18n/i18n.dart',
        'package:kurumi/material.dart',
        'package:material_symbols_icons/symbols.dart',
        'settings_environment.g.dart',
      ],
      [
        Enum(
          (b) => b
            ..name = 'SettingsSearchScope'
            ..values.addAll([
              EnumValue((v) => v.name = 'app'),
              EnumValue((v) => v.name = 'profile'),
            ]),
        ),
        category,
        Class(
          (b) => b
            ..name = '_Destination'
            ..constructors.add(
              Constructor(
                (c) => c
                  ..constant = true
                  ..optionalParameters.addAll([
                    for (final name in [
                      'label',
                      'target',
                      'parent',
                      'available',
                      'pageEntry',
                    ])
                      Parameter(
                        (p) => p
                          ..name = name
                          ..named = true
                          ..toThis = true
                          ..required = ['label', 'target'].contains(name)
                          ..defaultTo = name == 'pageEntry'
                              ? literalTrue.code
                              : null,
                      ),
                  ]),
              ),
            )
            ..fields.addAll([
              _field('label', 'String Function(Translations)'),
              _field('target', 'String'),
              _field('parent', 'SettingsCategory?'),
              _field('available', 'bool Function(SettingsEnvironment)?'),
              _field('pageEntry', 'bool'),
            ]),
        ),
        ...functions.methods,
      ],
    );
  }

  Parameter _named(String name, String type) => Parameter(
    (p) => p
      ..name = name
      ..type = refer(type)
      ..named = true,
  );
  Field _field(String name, String type) => Field(
    (f) => f
      ..name = name
      ..type = refer(type)
      ..modifier = FieldModifier.final$,
  );
  String _upper(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';

  Expression _predicate(
    Map<String, bool> conditions,
    _Functions functions, [
    List<int> boorus = const [],
  ]) {
    final names = conditions.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final name = names
        .map((e) => e.value ? e.key : 'not${_upper(e.key)}')
        .join('_');
    final membership = literalConstSet(
      boorus.toSet(),
    ).property('contains').call([refer('env').property('booruId')]);
    final expression = boorus.isEmpty
        ? _condition(conditions)
        : conditions.isEmpty
        ? membership.accept(_dart).toString()
        : '${_condition(conditions)} && ${membership.accept(_dart)}';
    return functions.use(
      name.isEmpty ? '_booruMatches' : '_condition_$name',
      'bool',
      expression,
      [
        ('env', 'SettingsEnvironment'),
      ],
    );
  }

  Map<String, bool> _extraConditions(String scope, CatalogPlacement binding) {
    final category =
        catalog.categories[binding.category]!.scopes[scope]!.condition;
    return {
      for (final entry in binding.condition.entries)
        if (category[entry.key] != entry.value) entry.key: entry.value,
    };
  }

  String _status(CatalogPlacement binding) {
    var expression = 'null';
    for (final status in binding.statuses.reversed) {
      final label = _label(status.text, arguments: status.arguments);
      expression = status.condition.isEmpty
          ? label
          : '${_condition(status.condition)} ? $label : $expression';
    }
    return expression;
  }

  String _placementKey(CatalogSetting setting) => jsonEncode([
    for (final entry
        in (setting.placements.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key))))
      [
        entry.key,
        entry.value.category,
        _condition(_extraConditions(entry.key, entry.value)),
        entry.value.boorus,
        entry.value.searchable,
        _status(entry.value),
      ],
  ]);

  Expression _placement(
    String scope,
    CatalogPlacement binding,
    String name,
    _Functions functions,
  ) {
    final condition = _extraConditions(scope, binding);
    return refer('SettingPlacement').constInstance([], {
      'scope': refer('SettingsSearchScope.$scope'),
      'category': refer('SettingsCategory.${binding.category}'),
      if (condition.isNotEmpty || binding.boorus.isNotEmpty)
        'available': _predicate(condition, functions, binding.boorus),
      if (!binding.searchable) 'searchable': literalFalse,
      if (binding.statuses.isNotEmpty)
        'status': functions.use('${name}Status', 'String?', _status(binding), [
          ('t', 'Translations'),
          ('env', 'SettingsEnvironment'),
          ('profileLabel', 'String'),
        ]),
    });
  }

  Expression _definition(CatalogSetting setting, String placements) =>
      refer('SettingDefinition').newInstance([], {
        'id': literalString(setting.id),
        'label': _expr('(t) => ${_label(setting.title)}'),
        if (setting.keywords.isNotEmpty)
          'keywords': literalString(setting.keywords.join(' ')),
        if (setting.description != null)
          'description': _expr('(t) => ${_label(setting.description!)}'),
        if (setting.section != null)
          'section': _expr('(t) => ${_label(setting.section!)}'),
        if (setting.options.isNotEmpty)
          'optionTerms': _expr(
            '(t) => [${setting.options.map(_label).join(', ')}].join(" ")',
          ),
        'placements': refer(placements),
      });

  String _settings() {
    final groups = <String, List<CatalogSetting>>{};
    final pools = <String, List<CatalogSetting>>{};
    for (final setting in catalog.settings.values) {
      groups.putIfAbsent(setting.group, () => []).add(setting);
      pools.putIfAbsent(_placementKey(setting), () => []).add(setting);
    }
    final common = <String, String>{};
    for (final entry in groups.entries) {
      final counts = <String, int>{};
      for (final setting in entry.value) {
        counts.update(
          _placementKey(setting),
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
      common[entry.key] =
          (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key;
    }
    final names = <String, String>{};
    final placements = <Spec>[];
    for (final entry in pools.entries) {
      final first = entry.value.first;
      final stem =
          '_${first.group}${common[first.group] == entry.key ? '' : '_${first.name}'}';
      names[entry.key] = '${stem}Placements';
    }
    final functions = _Functions(names.values);
    for (final entry in pools.entries) {
      final first = entry.value.first;
      final stem = names[entry.key]!;
      placements.add(
        Field(
          (f) => f
            ..name = names[entry.key]
            ..modifier = FieldModifier.constant
            ..assignment = literalConstList([
              for (final binding in first.placements.entries)
                _placement(
                  binding.key,
                  binding.value,
                  '$stem${_upper(binding.key)}',
                  functions,
                ),
            ]).code,
        ),
      );
    }
    return _library(
      [
        'package:i18n/i18n.dart',
        'settings_category.g.dart',
        'settings_environment.g.dart',
        '../types/settings_search_entry.dart',
      ],
      [
        for (final group in groups.entries)
          Class(
            (b) => b
              ..name = 'Settings${_upper(group.key)}'
              ..constructors.add(Constructor((c) => c.name = '_'))
              ..fields.addAll([
                for (final setting in group.value)
                  Field(
                    (f) => f
                      ..name = setting.name
                      ..modifier = FieldModifier.final$
                      ..assignment = _definition(
                        setting,
                        names[_placementKey(setting)]!,
                      ).code,
                  ),
              ]),
          ),
        Class((b) {
          b
            ..name = 'SettingsIndex'
            ..abstract = true;
          for (final group in groups.keys) {
            b.fields.add(
              Field(
                (f) => f
                  ..name = group
                  ..static = true
                  ..modifier = FieldModifier.final$
                  ..assignment = refer(
                    'Settings${_upper(group)}._',
                  ).call([]).code,
              ),
            );
          }
          b.fields.add(
            Field(
              (f) => f
                ..name = 'all'
                ..static = true
                ..modifier = FieldModifier.final$
                ..assignment = refer('List<SettingDefinition>.unmodifiable')
                    .call([
                      literalList(catalog.settings.keys.map(refer).toList()),
                    ])
                    .code,
            ),
          );
          for (final scope in ['app', 'profile']) {
            b.fields.add(
              Field(
                (f) => f
                  ..name = '_${scope}Settings'
                  ..static = true
                  ..modifier = FieldModifier.final$
                  ..assignment = _expr(
                    'List<SettingDefinition>.unmodifiable(all.where((setting) => setting.placements.any((placement) => placement.scope == SettingsSearchScope.$scope)))',
                  ).code,
              ),
            );
          }
          b.methods.add(
            Method(
              (m) => m
                ..name = 'forScope'
                ..static = true
                ..returns = refer('List<SettingDefinition>')
                ..requiredParameters.add(_param('scope', 'SettingsSearchScope'))
                ..lambda = true
                ..body = const Code(
                  'switch (scope) {SettingsSearchScope.app => _appSettings, SettingsSearchScope.profile => _profileSettings}',
                ),
            ),
          );
          b.fields.add(
            Field(
              (f) => f
                ..name = 'pages'
                ..static = true
                ..modifier = FieldModifier.final$
                ..assignment = _expr(
                  'List<SettingPageDefinition>.unmodifiable([for (final scope in SettingsSearchScope.values) for (final category in SettingsCategory.pagesForScope(scope)) SettingPageDefinition(scope: scope, category: category, keywords: category.keywords)])',
                ).code,
            ),
          );
        }),
        ...placements,
        ...functions.methods,
      ],
    );
  }
}

/// Intern identical callbacks within a generated library.
final class _Functions {
  _Functions([Iterable<String> reserved = const []]) : _used = reserved.toSet();
  final Set<String> _used;
  final _entries = <String, (String, Method)>{};
  Iterable<Method> get methods => _entries.values.map((entry) => entry.$2);

  Expression use(
    String name,
    String returns,
    String expression,
    List<(String, String)> parameters,
  ) {
    final key = jsonEncode([
      returns,
      expression,
      parameters.map((p) => [p.$1, p.$2]).toList(),
    ]);
    final existing = _entries[key];
    if (existing != null) return refer(existing.$1);
    var symbol = name;
    var suffix = 2;
    while (!_used.add(symbol)) {
      symbol = '$name${suffix++}';
    }
    final entry = _entries.putIfAbsent(
      key,
      () => (
        symbol,
        Method(
          (m) => m
            ..name = symbol
            ..returns = refer(returns)
            ..lambda = true
            ..body = Code(expression)
            ..requiredParameters.addAll([
              for (final (name, type) in parameters)
                Parameter(
                  (p) => p
                    ..name = name
                    ..type = refer(type),
                ),
            ]),
        ),
      ),
    );
    return refer(entry.$1);
  }
}
