/// String utility extensions and functions for code generation
extension StringExtension on String {
  /// Capitalize the first letter of a string
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

/// Convert kebab-case to camelCase
String kebabToCamel(String kebab) {
  final parts = kebab.split('-');
  if (parts.length == 1) return parts[0];

  return parts[0] +
      parts
          .skip(1)
          .map((part) => part[0].toUpperCase() + part.substring(1))
          .join('');
}

/// Convert snake_case to camelCase
String snakeToCamel(String snake) {
  final parts = snake.split('_');
  if (parts.length == 1) return parts[0];

  return parts[0] +
      parts
          .skip(1)
          .map((part) => part[0].toUpperCase() + part.substring(1))
          .join('');
}

/// Convert camelCase to kebab-case
String camelToKebab(String camel) {
  return camel
      .replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '-${match[0]!.toLowerCase()}',
      )
      .replaceFirst(RegExp(r'^-'), '');
}

/// Convert camelCase to snake_case
String camelToSnake(String camel) {
  return camel
      .replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '_${match[0]!.toLowerCase()}',
      )
      .replaceFirst(RegExp(r'^_'), '');
}
