import 'dart:io';

final class Env {
  const Env(this.values);

  final Map<String, String> values;

  static Env load(File file) {
    if (!file.existsSync()) return const Env({});

    final values = <String, String>{};
    for (final rawLine in file.readAsLinesSync()) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final index = line.indexOf('=');
      if (index <= 0) continue;
      final key = line.substring(0, index).trim();
      var value = line.substring(index + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      values[key] = value;
    }

    return Env(values);
  }

  String? operator [](String key) => values[key] ?? Platform.environment[key];
}
