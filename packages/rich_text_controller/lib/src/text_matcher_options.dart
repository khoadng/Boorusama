class TextMatcherOptions {
  const TextMatcherOptions({
    this.deleteOnBack = false,
    this.jumpOver = true,
  });

  final bool deleteOnBack;

  /// If true, the matcher will jump over its matches when moving the cursor.
  final bool jumpOver;
}
