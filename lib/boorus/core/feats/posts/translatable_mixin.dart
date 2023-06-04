mixin TranslatedMixin {
  List<String> get tags;

  bool get isTranslated => tags.contains('translated');
}
