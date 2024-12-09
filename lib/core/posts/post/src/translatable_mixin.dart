mixin TranslatedMixin {
  Set<String> get tags;

  bool get isTranslated =>
      tags.contains('translated') || tags.contains('check_translation');
}
