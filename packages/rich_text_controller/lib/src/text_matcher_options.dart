class TextMatcherOptions {
  const TextMatcherOptions({
    this.deleteOnBack = false,
    this.caseSensitive = true,
    this.dotAll = false,
    this.multiLine = false,
    this.unicode = false,
  });

  final bool deleteOnBack;
  final bool caseSensitive;
  final bool dotAll;
  final bool multiLine;
  final bool unicode;
}
