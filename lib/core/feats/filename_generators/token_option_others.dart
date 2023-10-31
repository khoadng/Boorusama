part of 'token_option.dart';

enum SortOptionValue {
  asc,
  desc,
  none,
}

enum SortAttribute {
  name,
  length,
  none,
}

extension SortOptionValueX on SortOptionValue {
  String get value => switch (this) {
        SortOptionValue.asc => 'asc',
        SortOptionValue.desc => 'desc',
        SortOptionValue.none => '',
      };
}

final class SortOption extends TokenOption with TokenValue<SortOptionValue> {
  SortOption({
    required this.value,
    required this.attribute,
  }) : super(name: 'sort');

  factory SortOption.parse({
    required String? value,
    required String? attribute,
  }) =>
      SortOption(
        value: switch (value) {
          'asc' => SortOptionValue.asc,
          'desc' => SortOptionValue.desc,
          _ => SortOptionValue.none,
        },
        attribute: switch (attribute) {
          'name' => SortAttribute.name,
          'length' => SortAttribute.length,
          _ => SortAttribute.none,
        },
      );

  @override
  final SortOptionValue value;
  final SortAttribute attribute;
}

enum StringCase {
  lower,
  upperFirst,
  upper,
  none,
}

final class CaseOption extends TokenOption with TokenValue<StringCase> {
  CaseOption({
    required this.value,
  }) : super(name: 'case');

  factory CaseOption.parse({
    required String? value,
  }) =>
      CaseOption(
        value: switch (value) {
          'lower' => StringCase.lower,
          'upper' => StringCase.upper,
          'upper_first' => StringCase.upperFirst,
          _ => StringCase.none,
        },
      );

  @override
  final StringCase value;
}

enum FloatingPointSeparatorType {
  dot,
  comma,
}

final class FloatingPointSeparator extends TokenOption
    with TokenValue<FloatingPointSeparatorType> {
  FloatingPointSeparator(
    this.value,
  ) : super(name: 'separator');

  factory FloatingPointSeparator.parse({
    required String? value,
  }) =>
      FloatingPointSeparator(
        switch (value) {
          'dot' => FloatingPointSeparatorType.dot,
          'comma' => FloatingPointSeparatorType.comma,
          _ => FloatingPointSeparatorType.dot,
        },
      );

  @override
  final FloatingPointSeparatorType value;
}
