extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

String kebabToCamel(String kebab) {
  final parts = kebab.split('-');
  if (parts.length == 1) return parts[0];

  return parts[0] +
      parts
          .skip(1)
          .map((part) => part[0].toUpperCase() + part.substring(1))
          .join('');
}
