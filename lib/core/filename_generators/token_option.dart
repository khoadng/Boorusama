// Package imports:
import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart' hide StringX;
import 'package:uuid/uuid.dart';

// Project imports:
import 'token.dart';
import 'utils.dart';

sealed class TokenOption extends Equatable {
  const TokenOption({
    required this.name,
  });

  final String name;

  @override
  List<Object?> get props => [name];
}

sealed class BooleanTokenOption extends TokenOption with TokenValue<bool> {
  BooleanTokenOption({
    required super.name,
    String? value,
  }) : value = value?.toBool() ?? true;

  @override
  final bool value;

  @override
  List<Object?> get props => [name, value];
}

sealed class IntegerTokenOption extends TokenOption with TokenValue<int> {
  IntegerTokenOption({
    required super.name,
    String? value,
  }) : value = value?.toInt() ?? 0;

  @override
  final int value;

  @override
  List<Object?> get props => [name, value];
}

sealed class StringTokenOption extends TokenOption with TokenValue<String> {
  StringTokenOption({
    required super.name,
    String? value,
  }) : value = value ?? '';

  @override
  final String value;

  @override
  List<Object?> get props => [name, value];
}

final class TokenOptionPair extends Equatable {
  const TokenOptionPair({
    required this.key,
    required this.value,
    required this.attribute,
  });

  factory TokenOptionPair.parse(String data) {
    final split = _splitString(data);

    return switch (split.length) {
      1 => TokenOptionPair(
          key: split[0]!,
          value: null,
          attribute: null,
        ),
      2 => TokenOptionPair(
          key: split[0]!,
          value: split[1],
          attribute: null,
        ),
      3 => TokenOptionPair(
          key: split[0]!,
          attribute: split[1],
          value: split[2],
        ),
      _ => const TokenOptionPair(
          key: '',
          value: null,
          attribute: null,
        ),
    };
  }

  final String key;
  final String? value;
  final String? attribute;

  @override
  List<Object?> get props => [key, value, attribute];
}

List<String?> _splitString(String input) {
  final result = <String>[];
  final bracketIndex = input.indexOf('[');

  if (bracketIndex != -1) {
    // if there is '[', split it by '[' and ']'
    final key = input.substring(0, bracketIndex);
    final rest = input.substring(bracketIndex + 1);
    final endIndex = rest.indexOf(']=');
    if (endIndex != -1) {
      final subKey = rest.substring(0, endIndex);
      final value = rest.substring(endIndex + 2); // skip ']='
      result.addAll([key, subKey, value]);
    }
  } else {
    // if there is no '[', split it by '='
    final int equalsIndex = input.indexOf('=');
    if (equalsIndex != -1) {
      final String key = input.substring(0, equalsIndex);
      final String value = input.substring(equalsIndex + 1);
      result.addAll([key, value]);
    } else {
      // if there is no '=', just add the input
      result.add(input);
    }
  }

  return result;
}

class TokenContext extends Equatable {
  const TokenContext({
    required this.token,
    required this.config,
    required this.options,
  });

  final Token token;
  final List<TokenOption> options;
  final TokenizerConfigs config;

  @override
  List<Object?> get props => [token, options, config];
}

mixin TokenValue<T> {
  T get value;
}

extension TokenOptionX on String {
  int toInt() => int.tryParse(this) ?? 0;
  bool toBool() => toLowerCase() == 'true';
}

typedef TokenOptionHandler = String Function(TokenContext context);
typedef TokenOptionDocs = ({
  TokenOption tokenOption,
  String description,
});

TokenOption getTokenOption(
  String? token,
  TokenOptionPair pair,
  TokenizerConfigs configs,
) =>
    switch (token.toOption().fold(
          () => pair.key,
          (t) => configs.namespacedTokens.contains(t)
              ? '$t:${pair.key}'
              : pair.key,
        )) {
      'maxlength' => MaxLengthOption(pair.value),
      'delimiter' => DelimiterOption(pair.value),
      'unsafe' => UnsafeOption(
          pair.value,
          unsafeCharacters: configs.unsafeCharacters,
        ),
      'format' => DateFormatOption(pair.value),
      'single_letter' => RatingSingleLetterOption(pair.value),
      'urlencode' => UrlEncodeOption(pair.value),
      'sort' => SortOption.parse(attribute: pair.attribute, value: pair.value),
      'case' => CaseOption.parse(value: pair.value),
      'nomod' => NoModifiersOption(pair.value),
      'limit' => LimitOption(pair.value),
      'index' => UniqueCounterOption(pair.value),
      'pad_left' => PadLeftOption(pair.value ?? ''),
      'include_namespace' => IncludeNamesOption(pair.value),
      'separator' => FloatingPointSeparator.parse(value: pair.value),
      'precision' => FloatingPointPrecisionOption(pair.value),
      'count' => CountOption(pair.value),
      'uuid:version' => UuidVersionOption.parse(value: pair.value),
      _ => UnknownOption(pair.key, pair.value ?? '')
    };

TokenOptionHandler getTokenOptionHandler(
  String data,
  TokenOption option, {
  required Uuid uuid,
  Clock? clock,
}) =>
    switch (option) {
      final CountOption o => (context) =>
          o.value ? data.split(' ').length.toString() : data,
      final MaxLengthOption o => (context) =>
          data.length > o.value ? data.substring(0, o.value) : data,
      final FloatingPointSeparator o => (context) => switch (o.value) {
            FloatingPointSeparatorType.comma => data.replaceAll('.', ','),
            FloatingPointSeparatorType.dot => data.replaceAll(',', '.'),
          },
      final FloatingPointPrecisionOption o => (context) => switch (o.value) {
            0 => data.toDoubleCommaAware()?.round().toString() ?? data,
            _ => data.toDoubleCommaAware()?.toStringAsFixed(o.value) ?? data,
          },
      final UuidVersionOption o => (context) => switch (o.value) {
            UuidVersion.v1 => uuid.v1(),
            UuidVersion.v4 => uuid.v4(),
          },
      final DelimiterOption o => (context) {
          final l = o.value.contains('comma')
              ? o.value.replaceAll('comma', ',')
              : o.value;

          return data.split(' ').join(l);
        },
      final UnsafeOption o => (context) => o.value
          ? data
          : data
              .split('')
              .map((e) => o.unsafeCharacters.contains(e) ? '_' : e)
              .join(),
      final DateFormatOption o => (context) =>
          DateFormat(o.value).format(clock?.now() ?? DateTime.now()),
      RatingSingleLetterOption _ => (context) => data.substring(0, 1),
      UrlEncodeOption _ => (context) => Uri.encodeComponent(data),
      final CaseOption o => (context) => switch (o.value) {
            StringCase.lower => data.toLowerCase(),
            StringCase.upper => data.toUpperCase(),
            StringCase.upperFirst => data.capitalize(),
            StringCase.none => data,
          },
      final SortOption o => (context) => switch ((o.attribute, o.value)) {
            (SortAttribute.name, SortOptionValue.asc) =>
              [...data.split(' ')..sort()].join(' '),
            (SortAttribute.name, SortOptionValue.desc) =>
              [...data.split(' ')..sort((a, b) => b.compareTo(a))].join(' '),
            (SortAttribute.length, SortOptionValue.asc) => [
                ...data.split(' ')..sort((a, b) => a.length.compareTo(b.length))
              ].join(' '),
            (SortAttribute.length, SortOptionValue.desc) => [
                ...data.split(' ')..sort((a, b) => b.length.compareTo(a.length))
              ].join(' '),
            _ => data,
          },
      final LimitOption o => (context) =>
          data.split(' ').take(o.value).join(' '),
      final NoModifiersOption o => (context) =>
          o.value ? cleanAndRemoveDuplicates(data.split(' ')).join(' ') : data,
      final UniqueCounterOption o => (context) => o.value ? data : '',
      final PadLeftOption o => (context) => data.padLeft(o.value, '0'),
      final IncludeNamesOption o => (context) =>
          o.value ? '${context.token.name}:$data' : data,
      UnknownOption _ => (context) => data,
    };

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
    String? value, {
    required this.unsafeCharacters,
  }) : super(name: 'unsafe', value: value);

  final List<String> unsafeCharacters;
}

final class NoModifiersOption extends BooleanTokenOption {
  NoModifiersOption(
    String? value,
  ) : super(name: 'nomod', value: value);
}

final class UniqueCounterOption extends BooleanTokenOption {
  UniqueCounterOption(
    String? value,
  ) : super(name: '_unique_counter', value: value);
}

final class IncludeNamesOption extends BooleanTokenOption {
  IncludeNamesOption(
    String? value,
  ) : super(name: 'include_namespace', value: value);
}

final class CountOption extends BooleanTokenOption {
  CountOption(
    String? value,
  ) : super(name: 'count', value: value);
}

final class MaxLengthOption extends IntegerTokenOption {
  MaxLengthOption(
    String? value,
  ) : super(name: 'maxlength', value: value);
}

final class PadLeftOption extends IntegerTokenOption {
  PadLeftOption(
    String? value,
  ) : super(name: 'pad_left', value: value);
}

final class LimitOption extends IntegerTokenOption {
  LimitOption(
    String? value,
  ) : super(name: 'limit', value: value);
}

final class FloatingPointPrecisionOption extends IntegerTokenOption {
  FloatingPointPrecisionOption(
    String? value,
  ) : super(name: 'precision', value: value);
}

final class DateFormatOption extends StringTokenOption {
  DateFormatOption(
    String? value,
  ) : super(name: 'format', value: value);
}

final class DelimiterOption extends StringTokenOption {
  DelimiterOption(
    String? value,
  ) : super(name: 'delimiter', value: value);
}

final class UnknownOption extends StringTokenOption {
  UnknownOption(
    String name,
    String? value,
  ) : super(name: name, value: value);
}

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

enum UuidVersion {
  v1,
  v4,
}

final class UuidVersionOption extends TokenOption with TokenValue<UuidVersion> {
  UuidVersionOption({
    required this.value,
  }) : super(name: 'uuid:version');

  factory UuidVersionOption.parse({
    required String? value,
  }) =>
      UuidVersionOption(
        value: switch (value) {
          '1' => UuidVersion.v1,
          '4' => UuidVersion.v4,
          _ => UuidVersion.v4,
        },
      );

  @override
  final UuidVersion value;
}
