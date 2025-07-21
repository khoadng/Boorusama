class LanguageData {
  const LanguageData({
    required this.locale,
    required this.name,
  });

  final String locale;
  final String name;

  @override
  String toString() => '$locale: $name';
}
