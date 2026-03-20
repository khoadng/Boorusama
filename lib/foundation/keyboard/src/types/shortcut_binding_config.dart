// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'key_binding.dart';

class ShortcutBindingConfig extends Equatable {
  const ShortcutBindingConfig({required this.bindings});
  const ShortcutBindingConfig.empty() : bindings = const {};

  factory ShortcutBindingConfig.fromJson(Map<String, dynamic> json) {
    final bindings = <String, KeyBinding>{};
    for (final entry in json.entries) {
      if (entry.value is Map<String, dynamic>) {
        bindings[entry.key] = KeyBinding.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
    }
    return ShortcutBindingConfig(bindings: bindings);
  }

  factory ShortcutBindingConfig.fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return const ShortcutBindingConfig.empty();
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return ShortcutBindingConfig.fromJson(decoded);
      }
      return const ShortcutBindingConfig.empty();
    } catch (_) {
      return const ShortcutBindingConfig.empty();
    }
  }

  final Map<String, KeyBinding> bindings;

  KeyBinding? bindingFor(String actionId) => bindings[actionId];

  ShortcutBindingConfig withBinding(String actionId, KeyBinding binding) {
    return ShortcutBindingConfig(
      bindings: {...bindings, actionId: binding},
    );
  }

  ShortcutBindingConfig removeBinding(String actionId) {
    return ShortcutBindingConfig(
      bindings: Map.of(bindings)..remove(actionId),
    );
  }

  /// Merges with defaults: keeps user bindings, fills in missing actions
  /// from [defaults]. Use this after loading from storage to ensure new
  /// actions added in app updates get their default bindings.
  ShortcutBindingConfig mergeWithDefaults(ShortcutBindingConfig defaults) {
    final merged = Map.of(defaults.bindings);
    merged.addAll(bindings);
    return ShortcutBindingConfig(bindings: merged);
  }

  Map<String, dynamic> toJson() {
    return bindings.map((key, value) => MapEntry(key, value.toJson()));
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  List<Object?> get props => [bindings];
}
