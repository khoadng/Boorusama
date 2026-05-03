final class PlaceholderValidator {
  const PlaceholderValidator();

  List<String> validate({
    required String key,
    required Object? baseValue,
    required String locale,
    required Object? localeValue,
  }) {
    final basePlaceholders = _extract(baseValue);
    final localePlaceholders = _extract(localeValue);

    if (basePlaceholders.isEmpty && localePlaceholders.isEmpty) {
      return const [];
    }

    final warnings = <String>[];
    final missing = basePlaceholders.difference(localePlaceholders);
    final extra = localePlaceholders.difference(basePlaceholders);

    if (missing.isNotEmpty) {
      warnings.add(
        '$locale:$key is missing placeholder(s): ${missing.join(', ')}',
      );
    }

    if (extra.isNotEmpty) {
      warnings.add(
        '$locale:$key has extra placeholder(s): ${extra.join(', ')}',
      );
    }

    return warnings;
  }

  Set<String> _extract(Object? value) {
    if (value is String) {
      return _extractFromString(value);
    }

    if (value is Map) {
      return {
        for (final entry in value.values) ..._extract(entry),
      };
    }

    if (value is Iterable) {
      return {
        for (final entry in value) ..._extract(entry),
      };
    }

    return const {};
  }

  Set<String> _extractFromString(String value) {
    final matches = RegExp(r'\$[A-Za-z_][A-Za-z0-9_]*').allMatches(value);

    return matches.map((match) => match.group(0)!).toSet();
  }
}
