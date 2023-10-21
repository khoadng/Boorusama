part of 'token_option.dart';

final class UrlEncodeOption extends BooleanTokenOption {
  UrlEncodeOption(
    String? value,
  ) : super(name: 'urlencode', value: value);
}

final class RatingSingleLetterOption extends BooleanTokenOption {
  RatingSingleLetterOption(
    String? value,
  ) : super(name: 'single_letter', value: value);
}

final class UnsafeOption extends BooleanTokenOption {
  UnsafeOption(
    String? value,
  ) : super(name: 'unsafe', value: value);
}

final class NoModifiersOption extends BooleanTokenOption {
  NoModifiersOption(
    String? value,
  ) : super(name: 'nomod', value: value);
}

final class UniqueCounterOption extends BooleanTokenOption {
  UniqueCounterOption(
    String? value,
  ) : super(name: 'unique_counter', value: value);
}

final class IncludeNamesOption extends BooleanTokenOption {
  IncludeNamesOption(
    String? value,
  ) : super(name: 'include_namespace', value: value);
}
