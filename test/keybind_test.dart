import 'package:boorusama/foundation/keyboard/src/types/key_binding.dart';
import 'package:boorusama/foundation/keyboard/src/types/shortcut_action.dart';
import 'package:boorusama/foundation/keyboard/src/types/shortcut_binding_config.dart';
import 'package:boorusama/foundation/keyboard/src/types/shortcut_registry.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _keyA = KeyBinding(key: LogicalKeyboardKey.keyA.keyId);
final _keyB = KeyBinding(key: LogicalKeyboardKey.keyB.keyId);
final _modA = KeyBinding(
  key: LogicalKeyboardKey.keyA.keyId,
  primaryModifier: true,
);
final _escape = KeyBinding(key: LogicalKeyboardKey.escape.keyId);
final _f5 = KeyBinding(key: LogicalKeyboardKey.f5.keyId);

KeybindRegistry _createRegistry() => KeybindRegistry([
  ShortcutActionInfo(
    id: 'a.one',
    context: ShortcutContext.global,
    defaultBinding: _keyA,
    labelBuilder: (_) => 'Action One',
  ),
  ShortcutActionInfo(
    id: 'a.two',
    context: ShortcutContext.global,
    defaultBinding: _keyB,
    labelBuilder: (_) => 'Action Two',
  ),
  ShortcutActionInfo(
    id: 'b.one',
    context: ShortcutContext.home,
    defaultBinding: _keyA,
    labelBuilder: (_) => 'Home Action',
  ),
]);

void main() {
  group('ShortcutBindingConfig', () {
    test('merging preserves user overrides and fills missing actions', () {
      final defaults = ShortcutBindingConfig(
        bindings: {
          'action.a': _keyA,
          'action.b': _keyB,
          'action.c': _escape,
        },
      );

      final userConfig = ShortcutBindingConfig(
        bindings: {
          'action.a': _modA,
        },
      );

      final merged = userConfig.mergeWithDefaults(defaults);

      expect(merged.bindingFor('action.a'), _modA);
      expect(merged.bindingFor('action.b'), _keyB);
      expect(merged.bindingFor('action.c'), _escape);
    });

    test('adding a binding returns config with new binding', () {
      final config = ShortcutBindingConfig(bindings: {'a': _keyA});
      final updated = config.withBinding('b', _keyB);

      expect(updated.bindingFor('a'), _keyA);
      expect(updated.bindingFor('b'), _keyB);
    });

    test('removing a binding returns config without it', () {
      final config = ShortcutBindingConfig(
        bindings: {
          'a': _keyA,
          'b': _keyB,
        },
      );
      final updated = config.removeBinding('a');

      expect(updated.bindingFor('a'), isNull);
      expect(updated.bindingFor('b'), _keyB);
    });

    final jsonCases = [
      (input: null, expected: 0, name: 'null'),
      (input: '', expected: 0, name: 'empty string'),
      (input: 'not json', expected: 0, name: 'invalid JSON'),
      (input: '[]', expected: 0, name: 'JSON array instead of object'),
    ];

    for (final c in jsonCases) {
      test('parsing ${c.name} returns empty config', () {
        final config = ShortcutBindingConfig.fromJsonString(c.input);
        expect(config.bindings, isEmpty);
      });
    }

    test('JSON roundtrip preserves bindings', () {
      final config = ShortcutBindingConfig(
        bindings: {
          'action.a': _modA,
          'action.b': _keyB,
        },
      );

      final restored = ShortcutBindingConfig.fromJsonString(
        config.toJsonString(),
      );

      expect(restored, config);
    });
  });

  group('KeybindRegistry conflict detection', () {
    test('detects conflict within same context', () {
      final registry = _createRegistry();
      final config = registry.defaultBindings();

      final conflict = registry.findConflict('a.one', _keyB, config);

      expect(conflict, 'a.two');
    });

    test('no conflict when binding is unique in context', () {
      final registry = _createRegistry();
      final config = registry.defaultBindings();

      final conflict = registry.findConflict('a.one', _f5, config);

      expect(conflict, isNull);
    });

    test('allows same key in different contexts', () {
      final registry = _createRegistry();
      final config = registry.defaultBindings();

      // 'b.one' (home context) uses keyA, same as 'a.one' (global context)
      final conflict = registry.findConflict('b.one', _keyA, config);

      // No conflict because they're in different contexts
      expect(conflict, isNull);
    });

    test('no conflict when reassigning same key to same action', () {
      final registry = _createRegistry();
      final config = registry.defaultBindings();

      final conflict = registry.findConflict('a.one', _keyA, config);

      expect(conflict, isNull);
    });
  });

  group('KeybindRegistry', () {
    test('generates default bindings from registered actions', () {
      final registry = _createRegistry();
      final defaults = registry.defaultBindings();

      expect(defaults.bindingFor('a.one'), _keyA);
      expect(defaults.bindingFor('a.two'), _keyB);
      expect(defaults.bindingFor('b.one'), _keyA);
    });

    test('groups actions by context', () {
      final registry = _createRegistry();
      final grouped = registry.grouped;

      expect(grouped[ShortcutContext.global], hasLength(2));
      expect(grouped[ShortcutContext.home], hasLength(1));
      expect(grouped[ShortcutContext.postDetails], isNull);
    });
  });

  group('KeyBinding', () {
    test('JSON roundtrip preserves all fields', () {
      final binding = KeyBinding(
        key: LogicalKeyboardKey.keyF.keyId,
        primaryModifier: true,
        shift: true,
      );

      final restored = KeyBinding.fromJson(binding.toJson());

      expect(restored, binding);
    });

    test('JSON omits false modifier flags', () {
      final json = _keyA.toJson();

      expect(json.containsKey('key'), isTrue);
      expect(json.containsKey('primaryModifier'), isFalse);
      expect(json.containsKey('secondaryModifier'), isFalse);
      expect(json.containsKey('shift'), isFalse);
      expect(json.containsKey('alt'), isFalse);
    });

    test('parses missing fields as defaults', () {
      final binding = KeyBinding.fromJson(const {'key': 42});

      expect(binding.key, 42);
      expect(binding.primaryModifier, isFalse);
      expect(binding.secondaryModifier, isFalse);
      expect(binding.shift, isFalse);
      expect(binding.alt, isFalse);
    });
  });
}
